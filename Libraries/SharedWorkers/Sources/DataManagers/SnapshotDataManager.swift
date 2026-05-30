//
//  SnapshotDataManager.swift
//  SharedWorkers
//
//  Created by Alena Nesterkina on 17.04.2026.
//

import Foundation
import SwiftData
import SharedModels
import SharedNetwork

@MainActor
public protocol ManagesSnapshotData {
    func getOrFetchSnapshot(for date: Date, portfolio: Portfolio) async throws -> PortfolioSnapshot
}

public enum SnapshotDataManagerError: LocalizedError {
    case dataNotFound
    case weekendDate(Date)
    
    public var errorDescription: String? {
        switch self {
        case .dataNotFound:
            "Data not found"
        case .weekendDate:
            "Portfolio history is unavailable for weekends"
        }
    }
}

public final class SnapshotDataManager: ManagesSnapshotData {
    private let eodhdNetworkService: EodhdNetworkServiceProtocol
    private let dataBase: SwiftDataBaseProtocol
    private let mapper: SwiftDataModelsMapper

    public init(dataBase: SwiftDataBaseProtocol, networkService: EodhdNetworkServiceProtocol) {
        self.dataBase = dataBase
        self.eodhdNetworkService = networkService
        self.mapper = SwiftDataModelsMapper()
    }
    
    public func getOrFetchSnapshot(for date: Date, portfolio: Portfolio) async throws -> PortfolioSnapshot {
        if date.isWeekend {
            throw SnapshotDataManagerError.weekendDate(date)
        }

        let porfolioEntity = try portfolioEntity(from: portfolio)

        if let existingSnapshot = porfolioEntity.snapshots.first(where: { $0.date.isSameDay(with: date) }) {
            return mapper.makePortfolioSnapshot(from: existingSnapshot)
        }
        
        let cashTransactions = portfolio.cashTransactions.filter { $0.date <= date }
        let dividendsTransactions = portfolio.dividendsTransactions.filter { $0.date <= date }
        let assetsTransactions = portfolio.assetsTransactions
            .filter { $0.date <= date }
            .sorted { $0.date < $1.date }
        
        var amounts: [Amount] = cashTransactions.map(\.amount) + dividendsTransactions.map(\.amount)
        var positions: [AssetTicker: SnapshotPosition] = [:]

        for transaction in assetsTransactions {
            let ticker = transaction.asset.ticker
            switch transaction.type {
            case .buy:
                amounts.append(
                    Amount(
                        value: -(transaction.amount.value + transaction.commision.value),
                        currency: transaction.amount.currency
                    )
                )
                positions[ticker, default: SnapshotPosition(asset: transaction.asset)].applyBuy(transaction)
            case .sell:
                amounts.append(
                    Amount(
                        value: transaction.amount.value - transaction.commision.value,
                        currency: transaction.amount.currency
                    )
                )
                positions[ticker, default: SnapshotPosition(asset: transaction.asset)].applySell(transaction)
            }
        }

        let cashAmount = AmountCalculator.sum(of: amounts)
        let realizedProfit = realizedProfit(in: portfolio, until: date)

        let portfolioSnaphotEntity = PortfolioSnapshotEntity(
            positions: [],
            date: date,
            name: portfolio.name,
            cache: cashAmount,
            realizedProfit: realizedProfit,
            portfolio: porfolioEntity
        )

        let positionEntities = try await positions.values
            .filter { $0.quantity > 0 }
            .asyncMap {
                let price = try await assetPrice(asset: $0.asset, for: date)
                let positionEntity = PositionSnapshotEntity(
                    asset: $0.asset.ticker,
                    quantity: $0.quantity,
                    price: Amount(value: $0.quantity * price.value, currency: price.currency),
                    openAmount: $0.openAmount,
                    portfolio: portfolioSnaphotEntity
                )
                dataBase.insert(entity: positionEntity)
                return positionEntity
            }
        portfolioSnaphotEntity.positions.append(contentsOf: positionEntities)
        porfolioEntity.snapshots.append(portfolioSnaphotEntity)
        dataBase.insert(entity: portfolioSnaphotEntity)
        try dataBase.save()

        return mapper.makePortfolioSnapshot(from: portfolioSnaphotEntity)
    }

    private func portfolioEntity(from portfolio: Portfolio) throws -> PortfolioEntity {
        let portfolioName = portfolio.name
        let descriptor = FetchDescriptor<PortfolioEntity>(
            predicate: #Predicate { $0.name == portfolioName }
        )

        if let existingPortfolio = try dataBase.fetch(descriptor: descriptor).first {
            return existingPortfolio
        }

        throw SnapshotDataManagerError.dataNotFound
    }
    
    private func assetPrice(asset: Asset, for date: Date) async throws -> Amount {
        let assetEntity = try assetEntity(for: asset)
        
        if let dayPrice = assetEntity.priceHistory.first(where: { $0.date.isSameDay(with: date) }) {
            return dayPrice.price
        } else {
            let prices = try await fetchAssetPrices(
                for: asset,
                fromDate: date.addingTimeInterval(-10 * 24 * 60 * 60), // 10 дней назад
                toDate: date
            )
            let entities = prices.map {
                let entity = AssetDayPriceEntity(date: $0.date, price: $0.price, asset: assetEntity)
                dataBase.insert(entity: entity)
                return entity
            }
            
            assetEntity.priceHistory.append(contentsOf: entities)
            try dataBase.save()
            
            if let dayPrice = prices.first(where: { $0.date.isSameDay(with: date) }) {
                return dayPrice.price
            } else {
                throw SnapshotDataManagerError.dataNotFound
            }
        }
    }
    
    private func assetEntity(for asset: Asset) throws -> AssetEntity {
        let ticker = asset.ticker.ticker
        let exchangeCode = asset.ticker.exchange.code
        let descriptor = FetchDescriptor<AssetEntity>(
            predicate: #Predicate { $0.ticker == ticker && $0.exchange.code == exchangeCode }
        )
        
        guard let asset = try dataBase.fetch(descriptor: descriptor).first else {
            throw SnapshotDataManagerError.dataNotFound
        }
        
        return asset
    }
    
    private func fetchAssetPrices(for asset: Asset, fromDate: Date, toDate: Date) async throws -> [AssetDayPrice] {
        let data = try await eodhdNetworkService.assetPrices(
            for: asset.ticker.ticker,
            exchange: asset.ticker.exchange.code,
            fromDate: fromDate,
            toDate: toDate
        )
        
        return data.map {
            AssetDayPrice(date: $0.date, price: Amount(value: $0.close, currency: asset.currency))
        }
    }

    private func realizedProfit(in portfolio: Portfolio, until date: Date) -> [Amount] {
        AmountCalculator.sum(
            of: portfolio.assetsTransactions
                .filter { $0.date <= date }
                .compactMap(\.type.realizedProfit)
        )
    }
}

private struct SnapshotPosition {
    let asset: Asset
    private(set) var quantity: Double
    private(set) var openAmount: Amount

    init(asset: Asset) {
        self.asset = asset
        self.quantity = 0
        self.openAmount = Amount(value: 0, currency: asset.currency)
    }

    mutating func applyBuy(_ transaction: AssetTransaction) {
        quantity += transaction.quantity
        openAmount = Amount(
            value: openAmount.value + transaction.amount.value + transaction.commision.value,
            currency: asset.currency
        )
    }

    mutating func applySell(_ transaction: AssetTransaction) {
        quantity = max(0, quantity - transaction.quantity)
        openAmount = Amount(
            value: max(0, openAmount.value - closedOpenAmount(for: transaction).value),
            currency: asset.currency
        )
    }

    private func closedOpenAmount(for transaction: AssetTransaction) -> Amount {
        if let amount = transaction.type.closedOpenAmount {
            return amount
        }

        guard let profit = transaction.type.realizedProfit else {
            return Amount(value: 0, currency: asset.currency)
        }

        return Amount(
            value: transaction.amount.value - transaction.commision.value - profit.value,
            currency: transaction.amount.currency
        )
    }
}

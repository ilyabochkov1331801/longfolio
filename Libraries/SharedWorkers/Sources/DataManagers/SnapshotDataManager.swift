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
        
        let cashTransactions = portfolio.cashTransactions.filter { $0.date <= date }
        let dividendsTransactions = portfolio.dividendsTransactions.filter { $0.date <= date }
        let assetsTransactions = portfolio.assetsTransactions.filter { $0.date <= date }
        
        var amounts: [Amount] = cashTransactions.map(\.amount) + dividendsTransactions.map(\.amount)
        var positions: [Asset: Position] = [:]
        
        for transaction in assetsTransactions {
            if let position = positions[transaction.asset] {
                let newQuantity: Double
                let newOpenAmount: Amount
                
                switch transaction.type {
                case .buy:
                    newQuantity = position.quantity + transaction.quantity
                    newOpenAmount = Amount(
                        value: position.openAmount.value + transaction.amount.value,
                        currency: position.asset.currency
                    )
                    amounts.append(
                        Amount(value: -transaction.amount.value, currency: transaction.amount.currency)
                    )
                case let .sell(profit):
                    newQuantity = position.quantity - transaction.quantity
                    newOpenAmount = Amount(
                        value: position.openAmount.value - transaction.amount.value + profit.value,
                        currency: position.asset.currency
                    )
                    amounts.append(transaction.amount)
                }
                
                positions[transaction.asset] = Position(
                    asset: position.asset, quantity: newQuantity, openAmount: newOpenAmount
                )
            } else {
                positions[transaction.asset] = Position(
                    asset: transaction.asset,
                    quantity: transaction.quantity,
                    openAmount: transaction.amount
                )
            }
        }
        
        let porfolioEntity = try portfolioEntity(from: portfolio)
        let cashAmount = AmountCalculator.sum(of: amounts)

        let portfolioSnaphotEntity = PortfolioSnapshotEntity(
            positions: [],
            date: date,
            name: portfolio.name,
            cache: cashAmount,
            portfolio: porfolioEntity
        )
        let positionEntities = try await positions.values.asyncMap {
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
}

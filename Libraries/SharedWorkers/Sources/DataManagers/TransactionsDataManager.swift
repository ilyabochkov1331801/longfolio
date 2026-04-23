//
//  TransactionsDataManager.swift
//  SharedWorkers
//
//  Created by Assistant on 07.04.26.
//

import Foundation
import SharedModels
import SwiftData

@MainActor
public protocol ManagesTransactionsData {
    func createCashTransaction(
        for portfolioName: String,
        amount: Amount,
        date: Date
    ) throws
    
    func createDividendTransaction(
        for portfolioName: String,
        asset: Asset,
        quantity: Double,
        amount: Amount,
        date: Date
    ) throws
    
    func createAssetTransaction(
        for portfolioName: String,
        asset: Asset,
        type: AssetTransactionType,
        quantity: Double,
        amount: Amount,
        date: Date
    ) throws
}

public enum TransactionsErrors: Error {
    case nothingToSell
}

public final class TransactionsDataManager: ManagesTransactionsData {
    private let dataBase: SwiftDataBaseProtocol
    private let assetsDataManager: ManagesAssetsData

    public init(dataBase: SwiftDataBaseProtocol) {
        self.dataBase = dataBase
        let assetsDataManager = AssetsDataManager(dataBase: dataBase)
        self.assetsDataManager = assetsDataManager
    }

    public func createCashTransaction(
        for portfolioName: String,
        amount: Amount,
        date: Date
    ) throws {
        let descriptor = FetchDescriptor<PortfolioEntity>(
            predicate: #Predicate { $0.name == portfolioName }
        )

        guard let portfolio = try dataBase.fetch(descriptor: descriptor).first else {
            return
        }

        let transaction = CashTransactionEntity(
            id: UUID().uuidString,
            date: date,
            amount: amount,
            portfolio: portfolio
        )

        portfolio.cashAmount = updateCashAmount(
            portfolio.cashAmount,
            with: amount
        )
        portfolio.cashTransactions.append(transaction)

        dataBase.insert(entity: transaction)

        try dataBase.save()
    }

    public func createDividendTransaction(
        for portfolioName: String,
        asset: Asset,
        quantity: Double,
        amount: Amount,
        date: Date
    ) throws {
        let portfolioDescriptor = FetchDescriptor<PortfolioEntity>(
            predicate: #Predicate { $0.name == portfolioName }
        )

        guard let portfolio = try dataBase.fetch(descriptor: portfolioDescriptor).first else {
            return
        }

        let assetEntity = try fetchOrCreateAsset(from: asset)

        let transaction = DividendTransactionEntity(
            id: UUID().uuidString,
            date: date,
            asset: assetEntity,
            quantity: quantity,
            amount: amount,
            portfolio: portfolio
        )

        portfolio.cashAmount = updateCashAmount(
            portfolio.cashAmount,
            with: amount
        )
        portfolio.dividendTransactions.append(transaction)

        dataBase.insert(entity: transaction)
        try dataBase.save()
    }

    public func createAssetTransaction(
        for portfolioName: String,
        asset: Asset,
        type: AssetTransactionType,
        quantity: Double,
        amount: Amount,
        date: Date
    ) throws {
        let portfolioDescriptor = FetchDescriptor<PortfolioEntity>(
            predicate: #Predicate { $0.name == portfolioName }
        )

        guard let portfolio = try dataBase.fetch(descriptor: portfolioDescriptor).first else {
            return
        }

        let assetEntity = try fetchOrCreateAsset(from: asset)
        
        let transaction = AssetTransactionEntity(
            id: UUID().uuidString,
            date: date,
            type: type,
            asset: assetEntity,
            quantity: quantity,
            amount: amount,
            portfolio: portfolio
        )

        let cashAmountDelta = Amount(
            value: type == .buy ? -amount.value : amount.value,
            currency: amount.currency
        )

        portfolio.cashAmount = updateCashAmount(
            portfolio.cashAmount,
            with: cashAmountDelta
        )
        portfolio.assetsTransactions.append(transaction)
        dataBase.insert(entity: transaction)

        try updatePosition(
            in: portfolio,
            asset: assetEntity,
            type: type,
            quantity: quantity,
            amount: amount
        )

        try dataBase.save()
    }

    private func updateCashAmount(_ currentAmounts: [Amount], with amount: Amount) -> [Amount] {
        var updatedAmounts = currentAmounts

        if let index = updatedAmounts.firstIndex(where: { $0.currency == amount.currency }) {
            let currentAmount = updatedAmounts[index]
            updatedAmounts[index] = Amount(
                value: currentAmount.value + amount.value,
                currency: amount.currency
            )
        } else {
            updatedAmounts.append(amount)
        }

        return updatedAmounts
    }

    private func fetchOrCreateExchange(from exchange: Exchange) throws -> ExchangeEntity {
        let exchangeCode = exchange.code
        let descriptor = FetchDescriptor<ExchangeEntity>(
            predicate: #Predicate { $0.code == exchangeCode }
        )

        if let existingExchange = try dataBase.fetch(descriptor: descriptor).first {
            return existingExchange
        }

        let newExchange = ExchangeEntity(
            name: exchange.name,
            code: exchange.code,
            country: exchange.country,
            currency: exchange.currency,
            assets: []
        )
        dataBase.insert(entity: newExchange)
        return newExchange
    }
    
    private func fetchOrCreateAsset(from asset: Asset) throws -> AssetEntity {
        let assetTicker = asset.ticker.ticker
        let exchangeCode = asset.ticker.exchange.code
        let descriptor = FetchDescriptor<AssetEntity>(
            predicate: #Predicate {
                $0.ticker == assetTicker && $0.exchange.code == exchangeCode
            }
        )

        if let existingAsset = try dataBase.fetch(descriptor: descriptor).first {
            return existingAsset
        }

        let exchange = try fetchOrCreateExchange(from: asset.ticker.exchange)
        let assetEntity = AssetEntity(
            priceHistory: [],
            ticker: assetTicker,
            currency: asset.currency,
            exchange: exchange,
            positions: []
        )
        let priceHistory = asset.priceHistory.map { dayPrice in
            AssetDayPriceEntity(date: dayPrice.date, price: dayPrice.price, asset: assetEntity)
        }
        assetEntity.priceHistory = priceHistory

        dataBase.insert(entity: assetEntity)
        return assetEntity
    }

    private func updatePosition(
        in portfolio: PortfolioEntity,
        asset: AssetEntity,
        type: AssetTransactionType,
        quantity: Double,
        amount: Amount
    ) throws {
        if let position = portfolio.positions.first(where: {
            $0.asset.ticker == asset.ticker && $0.asset.exchange.code == asset.exchange.code
        }) {
            switch type {
            case .buy:
                position.quantity = position.quantity + quantity
                position.openAmount = Amount(
                    value: position.openAmount.value + amount.value,
                    currency: amount.currency
                )
            case let .sell(profit):
                position.quantity = max(0, position.quantity - quantity)
                position.openAmount = Amount(
                    value: max(0, position.openAmount.value - (amount.value - profit.value)),
                    currency: amount.currency
                )
            }

            return
        }

        guard type == .buy else {
            throw TransactionsErrors.nothingToSell
        }

        let newPosition = PositionEntity(
            asset: asset,
            quantity: quantity,
            openAmount: amount,
            portfolio: portfolio
        )
        asset.positions.append(newPosition)
        portfolio.positions.append(newPosition)
        
        dataBase.insert(entity: newPosition)
    }
}

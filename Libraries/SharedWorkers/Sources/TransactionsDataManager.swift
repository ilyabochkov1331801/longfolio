//
//  TransactionsDataManager.swift
//  SharedWorkers
//
//  Created by Assistant on 07.04.26.
//

import Foundation
import SharedModels
import SwiftData

public protocol ManagesTransactionsData {
    func createCashTransaction(
        for portfolioName: String,
        amount: Amount,
        date: Date
    ) throws
    func createDividendTransaction(
        for portfolioName: String,
        asset: AssetTicker,
        quantity: Double,
        amount: Amount,
        date: Date
    ) throws
    func createAssetTransaction(
        for portfolioName: String,
        asset: AssetTicker,
        type: AssetTransactionType,
        quantity: Double,
        amount: Amount,
        date: Date
    ) throws
}

public final class TransactionsDataManager: ManagesTransactionsData {
    private let dataBase: SwiftDataBaseProtocol

    public init(dataBase: SwiftDataBaseProtocol) {
        self.dataBase = dataBase
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
        asset: AssetTicker,
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

        let exchange = try fetchOrCreateExchange(from: asset.exchange)
        let ticker = try fetchOrCreateTicker(from: asset, exchange: exchange)

        let transaction = DividendTransactionEntity(
            id: UUID().uuidString,
            date: date,
            ticker: ticker,
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
        asset: AssetTicker,
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

        let exchange = try fetchOrCreateExchange(from: asset.exchange)
        let ticker = try fetchOrCreateTicker(from: asset, exchange: exchange)

        let transaction = AssetTransactionEntity(
            id: UUID().uuidString,
            date: date,
            type: type,
            ticker: ticker,
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
            ticker: ticker,
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
            tickers: []
        )
        dataBase.insert(entity: newExchange)
        return newExchange
    }

    private func fetchOrCreateTicker(from asset: AssetTicker, exchange: ExchangeEntity) throws -> AssetTickerEntity {
        let assetTicker = asset.ticker
        let exchangeCode = asset.exchange.code
        let descriptor = FetchDescriptor<AssetTickerEntity>(
            predicate: #Predicate {
                $0.ticker == assetTicker && $0.exchange.code == exchangeCode
            }
        )

        if let existingTicker = try dataBase.fetch(descriptor: descriptor).first {
            return existingTicker
        }

        let newTicker = AssetTickerEntity(ticker: asset.ticker, exchange: exchange)
        dataBase.insert(entity: newTicker)
        return newTicker
    }

    private func updatePosition(
        in portfolio: PortfolioEntity,
        ticker: AssetTickerEntity,
        type: AssetTransactionType,
        quantity: Double,
        amount: Amount
    ) throws {
        if let position = portfolio.positions.first(where: {
            $0.ticker.ticker == ticker.ticker && $0.ticker.exchange.code == ticker.exchange.code
        }) {
            switch type {
            case .buy:
                let totalOpenAmount = position.averageOpenPrice.value * position.quantity + amount.value
                let newQuantity = position.quantity + quantity
                position.quantity = newQuantity
                position.averageOpenPrice = Amount(
                    value: newQuantity == 0 ? 0 : totalOpenAmount / newQuantity,
                    currency: amount.currency
                )
            case .sell:
                position.quantity = max(0, position.quantity - quantity)
            }

            return
        }

        guard type == .buy else { return }

        let newPosition = PositionEntity(
            ticker: ticker,
            quantity: quantity,
            averageOpenPrice: Amount(
                value: quantity == 0 ? 0 : amount.value / quantity,
                currency: amount.currency
            ),
            portfolio: portfolio
        )
        portfolio.positions.append(newPosition)
        dataBase.insert(entity: newPosition)
    }
}

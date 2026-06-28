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
        amount: Amount,
        paidTaxes: Amount,
        date: Date
    ) throws
    
    func createBuyAssetTransaction(
        for portfolioName: String,
        asset: Asset,
        quantity: Double,
        amount: Amount,
        commision: Amount,
        date: Date
    ) throws
    
    func createSellAssetTransaction(
        for portfolioName: String,
        asset: Asset,
        quantity: Double,
        amount: Amount,
        commision: Amount,
        date: Date
    ) throws

    func createSellAssetLotTransaction(
        for portfolioName: String,
        lot: AssetLot,
        quantity: Double,
        amount: Amount,
        commision: Amount,
        date: Date
    ) throws

    func updateCashTransactionDate(id: String, date: Date) throws
    func updateDividendTransactionDate(id: String, date: Date) throws
    func updateAssetTransactionDate(id: String, isSell: Bool, date: Date) throws
    func updateCashTransaction(id: String, amount: Amount, date: Date) throws
    func updateDividendTransaction(id: String, asset: Asset, amount: Amount, paidTaxes: Amount, date: Date) throws
    func updateBuyAssetTransaction(id: String, asset: Asset, quantity: Double, amount: Amount, commision: Amount, date: Date) throws
    func updateSellAssetTransaction(id: String, asset: Asset, quantity: Double, amount: Amount, commision: Amount, date: Date) throws
    func deleteCashTransaction(id: String) throws
    func deleteDividendTransaction(id: String) throws
    func deleteAssetTransaction(id: String, isSell: Bool) throws
}

public enum TransactionsErrors: Error {
    case nothingToSell
    case notEnoughQuantity
    case lotNotFound
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
        clearSnapshots(in: portfolio, from: date)

        dataBase.insert(entity: transaction)

        try dataBase.save()
    }

    public func createDividendTransaction(
        for portfolioName: String,
        asset: Asset,
        amount: Amount,
        paidTaxes: Amount,
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
            amount: amount,
            paidTaxes: paidTaxes,
            portfolio: portfolio
        )

        portfolio.cashAmount = updateCashAmount(
            portfolio.cashAmount,
            with: amount
        )
        portfolio.dividendTransactions.append(transaction)
        clearSnapshots(in: portfolio, from: date)

        dataBase.insert(entity: transaction)
        try dataBase.save()
    }
    
    public func createBuyAssetTransaction(
        for portfolioName: String,
        asset: Asset,
        quantity: Double,
        amount: Amount,
        commision: Amount,
        date: Date
    ) throws {
        let portfolioDescriptor = FetchDescriptor<PortfolioEntity>(
            predicate: #Predicate { $0.name == portfolioName }
        )

        guard let portfolio = try dataBase.fetch(descriptor: portfolioDescriptor).first else {
            return
        }

        let assetEntity = try fetchOrCreateAsset(from: asset)
        let transaction = BuyAssetTransactionEntity(
            id: UUID().uuidString,
            date: date,
            asset: assetEntity,
            quantity: quantity,
            amount: amount,
            commision: commision,
            portfolio: portfolio
        )
        
        portfolio.cashAmount = updateCashAmount(
            portfolio.cashAmount,
            with: Amount(
                value: -(amount.value + commision.value),
                currency: amount.currency
            )
        )
        portfolio.buyAssetsTransactions.append(transaction)
        clearSnapshots(in: portfolio, from: date)
        dataBase.insert(entity: transaction)
        
        let lotEntity = AssetLotEntity(
            id: UUID(),
            asset: assetEntity,
            quantity: quantity,
            openAmount: amount,
            date: date
        )
        dataBase.insert(entity: lotEntity)
        
        if let position = portfolio.positions.first(where: { $0.asset.ticker == asset.ticker.ticker && $0.asset.exchange.code == asset.ticker.exchange.code }) {
            position.lots.append(lotEntity)
        } else {
            let newPosition = PositionEntity(
                asset: assetEntity,
                lots: [lotEntity],
                portfolio: portfolio
            )
            assetEntity.positions.append(newPosition)
            portfolio.positions.append(newPosition)
            
            dataBase.insert(entity: newPosition)
        }
        
        try dataBase.save()
    }
    
    public func createSellAssetTransaction(
        for portfolioName: String,
        asset: Asset,
        quantity: Double,
        amount: Amount,
        commision: Amount,
        date: Date
    ) throws {
        let portfolioDescriptor = FetchDescriptor<PortfolioEntity>(
            predicate: #Predicate { $0.name == portfolioName }
        )

        guard
            let portfolio = try dataBase.fetch(descriptor: portfolioDescriptor).first,
            let position = portfolio.positions.first(where: { $0.asset.ticker == asset.ticker.ticker && $0.asset.exchange.code == asset.ticker.exchange.code })
        else {
            throw TransactionsErrors.nothingToSell
        }

        let assetEntity = position.asset
        let availableQuantity = position.lots.reduce(0.0) { $0 + $1.quantity }

        guard availableQuantity >= quantity else {
            throw TransactionsErrors.notEnoughQuantity
        }
        
        var closedLots: [AssetLotEntity] = []
        var unclosedQuantity = quantity
        for lot in position.lots.sorted(by: { $0.date < $1.date }) {
            guard unclosedQuantity > 0 else { break }

            if lot.quantity > unclosedQuantity {
                let separatedLot = AssetLotEntity(
                    id: UUID(),
                    asset: assetEntity,
                    quantity: unclosedQuantity,
                    openAmount: Amount(
                        value: lot.unitOpenAmount * unclosedQuantity,
                        currency: lot.openAmount.currency
                    ),
                    date: lot.date
                )
                lot.quantity -= unclosedQuantity
                lot.openAmount = Amount(
                    value: lot.openAmount.value - separatedLot.openAmount.value,
                    currency: lot.openAmount.currency
                )
                dataBase.insert(entity: separatedLot)
                closedLots.append(separatedLot)
                break
            } else {
                closedLots.append(lot)
                unclosedQuantity -= lot.quantity
                position.lots.removeAll(where: { $0.id == lot.id })
            }
        }
        
        let closedLotsOpenAmount = closedLots.reduce(0, { $0 + $1.openAmount.value })
        let profit = Amount(
            value: amount.value - closedLotsOpenAmount,
            currency: amount.currency
        )
        
        let transaction = SellAssetTransactionEntity(
            id: UUID().uuidString,
            asset: assetEntity,
            date: date,
            quantity: quantity,
            amount: amount,
            commision: commision,
            portfolio: portfolio,
            closedLots: closedLots,
            profit: profit
        )
        
        portfolio.cashAmount = updateCashAmount(
            portfolio.cashAmount,
            with: Amount(
                value: amount.value - commision.value,
                currency: amount.currency
            )
        )
        portfolio.realizedProfit = updateAmount(
            portfolio.realizedProfit,
            with: profit
        )
        portfolio.sellAssetsTransactions.append(transaction)
        clearSnapshots(in: portfolio, from: date)
        dataBase.insert(entity: transaction)

        if position.lots.isEmpty {
            dataBase.delete(entity: position)
        }
        
        try dataBase.save()
    }

    public func createSellAssetLotTransaction(
        for portfolioName: String,
        lot: AssetLot,
        quantity: Double,
        amount: Amount,
        commision: Amount,
        date: Date
    ) throws {
        let portfolioDescriptor = FetchDescriptor<PortfolioEntity>(
            predicate: #Predicate { $0.name == portfolioName }
        )

        guard
            let portfolio = try dataBase.fetch(descriptor: portfolioDescriptor).first,
            let position = portfolio.positions.first(where: { $0.asset.ticker == lot.asset.ticker.ticker && $0.asset.exchange.code == lot.asset.ticker.exchange.code })
        else {
            throw TransactionsErrors.nothingToSell
        }

        guard let lotEntity = position.lots.first(where: { $0.id == lot.id }) else {
            throw TransactionsErrors.lotNotFound
        }

        guard lotEntity.quantity >= quantity else {
            throw TransactionsErrors.notEnoughQuantity
        }

        let assetEntity = position.asset
        let closedLot: AssetLotEntity

        if lotEntity.quantity > quantity {
            let separatedLot = AssetLotEntity(
                id: UUID(),
                asset: assetEntity,
                quantity: quantity,
                openAmount: Amount(
                    value: lotEntity.unitOpenAmount * quantity,
                    currency: lotEntity.openAmount.currency
                ),
                date: lotEntity.date
            )
            lotEntity.quantity -= quantity
            lotEntity.openAmount = Amount(
                value: lotEntity.openAmount.value - separatedLot.openAmount.value,
                currency: lotEntity.openAmount.currency
            )
            dataBase.insert(entity: separatedLot)
            closedLot = separatedLot
        } else {
            closedLot = lotEntity
            position.lots.removeAll(where: { $0.id == lot.id })
        }

        let profit = Amount(
            value: amount.value - closedLot.openAmount.value,
            currency: amount.currency
        )
        let transaction = SellAssetTransactionEntity(
            id: UUID().uuidString,
            asset: assetEntity,
            date: date,
            quantity: quantity,
            amount: amount,
            commision: commision,
            portfolio: portfolio,
            closedLots: [closedLot],
            profit: profit
        )

        portfolio.cashAmount = updateCashAmount(
            portfolio.cashAmount,
            with: Amount(
                value: amount.value - commision.value,
                currency: amount.currency
            )
        )
        portfolio.realizedProfit = updateAmount(
            portfolio.realizedProfit,
            with: profit
        )
        portfolio.sellAssetsTransactions.append(transaction)
        clearSnapshots(in: portfolio, from: date)
        dataBase.insert(entity: transaction)

        if position.lots.isEmpty {
            portfolio.positions.removeAll(where: { $0.asset.ticker == lot.asset.ticker.ticker && $0.asset.exchange.code == lot.asset.ticker.exchange.code })
            dataBase.delete(entity: position)
        }

        try dataBase.save()
    }

    public func updateCashTransactionDate(id: String, date: Date) throws {
        let descriptor = FetchDescriptor<CashTransactionEntity>(
            predicate: #Predicate { $0.id == id }
        )

        guard let transaction = try dataBase.fetch(descriptor: descriptor).first else {
            return
        }

        try updateCashTransaction(id: id, amount: transaction.amount, date: date)
    }

    public func updateDividendTransactionDate(id: String, date: Date) throws {
        let descriptor = FetchDescriptor<DividendTransactionEntity>(
            predicate: #Predicate { $0.id == id }
        )

        guard let transaction = try dataBase.fetch(descriptor: descriptor).first else {
            return
        }

        try updateDividendTransaction(
            transaction,
            asset: transaction.asset,
            amount: transaction.amount,
            paidTaxes: transaction.paidTaxes,
            date: date
        )
    }

    public func updateAssetTransactionDate(id: String, isSell: Bool, date: Date) throws {
        if isSell {
            let descriptor = FetchDescriptor<SellAssetTransactionEntity>(
                predicate: #Predicate { $0.id == id }
            )

            guard let transaction = try dataBase.fetch(descriptor: descriptor).first else {
                return
            }

            let previousDate = transaction.date
            transaction.date = date

            do {
                try recalculatePortfolioState(in: transaction.portfolio)
            } catch {
                transaction.date = previousDate
                try? recalculatePortfolioState(in: transaction.portfolio)
                throw error
            }

            try dataBase.save()
        } else {
            let descriptor = FetchDescriptor<BuyAssetTransactionEntity>(
                predicate: #Predicate { $0.id == id }
            )

            guard let transaction = try dataBase.fetch(descriptor: descriptor).first else {
                return
            }

            let previousDate = transaction.date
            transaction.date = date

            do {
                try recalculatePortfolioState(in: transaction.portfolio)
            } catch {
                transaction.date = previousDate
                try? recalculatePortfolioState(in: transaction.portfolio)
                throw error
            }

            try dataBase.save()
        }
    }

    public func updateCashTransaction(id: String, amount: Amount, date: Date) throws {
        let descriptor = FetchDescriptor<CashTransactionEntity>(
            predicate: #Predicate { $0.id == id }
        )

        guard let transaction = try dataBase.fetch(descriptor: descriptor).first else {
            return
        }

        transaction.amount = amount
        transaction.date = date
        try recalculatePortfolioState(in: transaction.portfolio)
        try dataBase.save()
    }

    public func updateDividendTransaction(id: String, asset: Asset, amount: Amount, paidTaxes: Amount, date: Date) throws {
        let descriptor = FetchDescriptor<DividendTransactionEntity>(
            predicate: #Predicate { $0.id == id }
        )

        guard let transaction = try dataBase.fetch(descriptor: descriptor).first else {
            return
        }

        let assetEntity = try fetchOrCreateAsset(from: asset)

        try updateDividendTransaction(
            transaction,
            asset: assetEntity,
            amount: amount,
            paidTaxes: paidTaxes,
            date: date
        )
    }

    private func updateDividendTransaction(
        _ transaction: DividendTransactionEntity,
        asset: AssetEntity,
        amount: Amount,
        paidTaxes: Amount,
        date: Date
    ) throws {
        let previous = (transaction.asset, transaction.amount, transaction.paidTaxes, transaction.date)

        transaction.asset = asset
        transaction.amount = amount
        transaction.paidTaxes = paidTaxes
        transaction.date = date

        do {
            try recalculatePortfolioState(in: transaction.portfolio)
        } catch {
            transaction.asset = previous.0
            transaction.amount = previous.1
            transaction.paidTaxes = previous.2
            transaction.date = previous.3
            try? recalculatePortfolioState(in: transaction.portfolio)
            throw error
        }

        try dataBase.save()
    }

    public func updateBuyAssetTransaction(id: String, asset: Asset, quantity: Double, amount: Amount, commision: Amount, date: Date) throws {
        let descriptor = FetchDescriptor<BuyAssetTransactionEntity>(
            predicate: #Predicate { $0.id == id }
        )

        guard let transaction = try dataBase.fetch(descriptor: descriptor).first else {
            return
        }

        let assetEntity = try fetchOrCreateAsset(from: asset)
        let previous = (transaction.asset, transaction.quantity, transaction.amount, transaction.commision, transaction.date)
        transaction.asset = assetEntity
        transaction.quantity = quantity
        transaction.amount = amount
        transaction.commision = commision
        transaction.date = date

        do {
            try recalculatePortfolioState(in: transaction.portfolio)
        } catch {
            transaction.asset = previous.0
            transaction.quantity = previous.1
            transaction.amount = previous.2
            transaction.commision = previous.3
            transaction.date = previous.4
            try? recalculatePortfolioState(in: transaction.portfolio)
            throw error
        }

        try dataBase.save()
    }

    public func updateSellAssetTransaction(id: String, asset: Asset, quantity: Double, amount: Amount, commision: Amount, date: Date) throws {
        let descriptor = FetchDescriptor<SellAssetTransactionEntity>(
            predicate: #Predicate { $0.id == id }
        )

        guard let transaction = try dataBase.fetch(descriptor: descriptor).first else {
            return
        }

        let assetEntity = try fetchOrCreateAsset(from: asset)
        let previous = (transaction.asset, transaction.quantity, transaction.amount, transaction.commision, transaction.date)
        transaction.asset = assetEntity
        transaction.quantity = quantity
        transaction.amount = amount
        transaction.commision = commision
        transaction.date = date

        do {
            try recalculatePortfolioState(in: transaction.portfolio)
        } catch {
            transaction.asset = previous.0
            transaction.quantity = previous.1
            transaction.amount = previous.2
            transaction.commision = previous.3
            transaction.date = previous.4
            try? recalculatePortfolioState(in: transaction.portfolio)
            throw error
        }

        try dataBase.save()
    }

    public func deleteCashTransaction(id: String) throws {
        let descriptor = FetchDescriptor<CashTransactionEntity>(
            predicate: #Predicate { $0.id == id }
        )

        guard let transaction = try dataBase.fetch(descriptor: descriptor).first else {
            return
        }

        let portfolio = transaction.portfolio
        portfolio.cashTransactions.removeAll { $0.id == id }
        dataBase.delete(entity: transaction)
        try recalculatePortfolioState(in: portfolio)
        try dataBase.save()
    }

    public func deleteDividendTransaction(id: String) throws {
        let descriptor = FetchDescriptor<DividendTransactionEntity>(
            predicate: #Predicate { $0.id == id }
        )

        guard let transaction = try dataBase.fetch(descriptor: descriptor).first else {
            return
        }

        let portfolio = transaction.portfolio
        portfolio.dividendTransactions.removeAll { $0.id == id }
        dataBase.delete(entity: transaction)
        try recalculatePortfolioState(in: portfolio)
        try dataBase.save()
    }

    public func deleteAssetTransaction(id: String, isSell: Bool) throws {
        if isSell {
            let descriptor = FetchDescriptor<SellAssetTransactionEntity>(
                predicate: #Predicate { $0.id == id }
            )

            guard let transaction = try dataBase.fetch(descriptor: descriptor).first else {
                return
            }

            let portfolio = transaction.portfolio
            try validateAssetTransactions(in: portfolio, excluding: id)
            let closedLots = transaction.closedLots
            transaction.closedLots.removeAll()
            portfolio.sellAssetsTransactions.removeAll { $0.id == id }
            dataBase.delete(entity: transaction)
            closedLots.forEach { dataBase.delete(entity: $0) }
            try recalculatePortfolioState(in: portfolio)
            try dataBase.save()
            return
        }

        let descriptor = FetchDescriptor<BuyAssetTransactionEntity>(
            predicate: #Predicate { $0.id == id }
        )

        guard let transaction = try dataBase.fetch(descriptor: descriptor).first else {
            return
        }

        let portfolio = transaction.portfolio
        try validateAssetTransactions(in: portfolio, excluding: id)
        portfolio.buyAssetsTransactions.removeAll { $0.id == id }
        dataBase.delete(entity: transaction)
        try recalculatePortfolioState(in: portfolio)
        try dataBase.save()
    }

    private func updateCashAmount(_ currentAmounts: [Amount], with amount: Amount) -> [Amount] {
        updateAmount(currentAmounts, with: amount)
    }

    private func clearSnapshots(in portfolio: PortfolioEntity) {
        let snapshots = portfolio.snapshots
        portfolio.snapshots.removeAll()
        snapshots.forEach { dataBase.delete(entity: $0) }
    }

    private func clearSnapshots(in portfolio: PortfolioEntity, from date: Date) {
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: date)
        let snapshots = portfolio.snapshots.filter {
            calendar.startOfDay(for: $0.date) >= startDate
        }

        portfolio.snapshots.removeAll {
            calendar.startOfDay(for: $0.date) >= startDate
        }
        snapshots.forEach { dataBase.delete(entity: $0) }
    }

    private func recalculatePortfolioState(in portfolio: PortfolioEntity) throws {
        clearPositions(in: portfolio)

        let assetTransactions = (
            portfolio.buyAssetsTransactions.map(AssetTransactionEntity.buy) +
            portfolio.sellAssetsTransactions.map(AssetTransactionEntity.sell)
        ).sorted { lhs, rhs in
            if lhs.date == rhs.date {
                return lhs.sortPriority < rhs.sortPriority
            }
            return lhs.date < rhs.date
        }

        for transaction in assetTransactions {
            switch transaction {
            case let .buy(transaction):
                try applyBuyTransaction(transaction, to: portfolio)
            case let .sell(transaction):
                try applySellTransaction(transaction, to: portfolio)
            }
        }

        let cashTransactions = portfolio.cashTransactions.map(\.amount)
        let dividendTransactions = portfolio.dividendTransactions.map(\.amount)
        let buyTransactions = portfolio.buyAssetsTransactions.map {
            Amount(value: -($0.amount.value + $0.commision.value), currency: $0.amount.currency)
        }
        let sellTransactions = portfolio.sellAssetsTransactions.map {
            Amount(value: $0.amount.value - $0.commision.value, currency: $0.amount.currency)
        }

        portfolio.cashAmount = AmountCalculator.sum(
            of: cashTransactions + dividendTransactions + buyTransactions + sellTransactions
        )
        portfolio.realizedProfit = AmountCalculator.sum(
            of: portfolio.sellAssetsTransactions.map(\.profit)
        )
        clearSnapshots(in: portfolio)
    }

    private func clearPositions(in portfolio: PortfolioEntity) {
        let lots = portfolio.positions.flatMap(\.lots) + portfolio.sellAssetsTransactions.flatMap(\.closedLots)
        var deletedLotIDs: Set<UUID> = []

        portfolio.sellAssetsTransactions.forEach { $0.closedLots.removeAll() }
        portfolio.positions.forEach { dataBase.delete(entity: $0) }
        portfolio.positions.removeAll()

        for lot in lots where !deletedLotIDs.contains(lot.id) {
            deletedLotIDs.insert(lot.id)
            dataBase.delete(entity: lot)
        }
    }

    private func applyBuyTransaction(_ transaction: BuyAssetTransactionEntity, to portfolio: PortfolioEntity) throws {
        guard transaction.quantity > 0, transaction.amount.value > 0 else {
            throw TransactionsErrors.notEnoughQuantity
        }

        let position = position(for: transaction.asset, in: portfolio) ?? createPosition(
            for: transaction.asset,
            in: portfolio
        )
        let lot = AssetLotEntity(
            id: UUID(),
            asset: transaction.asset,
            quantity: transaction.quantity,
            openAmount: transaction.amount,
            date: transaction.date
        )
        dataBase.insert(entity: lot)
        position.lots.append(lot)
    }

    private func applySellTransaction(_ transaction: SellAssetTransactionEntity, to portfolio: PortfolioEntity) throws {
        guard transaction.quantity > 0, transaction.amount.value > 0 else {
            throw TransactionsErrors.notEnoughQuantity
        }

        guard let position = position(for: transaction.asset, in: portfolio) else {
            throw TransactionsErrors.nothingToSell
        }

        let availableQuantity = position.lots.reduce(0.0) { $0 + $1.quantity }
        guard availableQuantity >= transaction.quantity else {
            throw TransactionsErrors.notEnoughQuantity
        }

        var closedLots: [AssetLotEntity] = []
        var unclosedQuantity = transaction.quantity

        for lot in position.lots.sorted(by: { $0.date < $1.date }) {
            guard unclosedQuantity > 0 else { break }

            if lot.quantity > unclosedQuantity {
                let separatedLot = AssetLotEntity(
                    id: UUID(),
                    asset: transaction.asset,
                    quantity: unclosedQuantity,
                    openAmount: Amount(
                        value: lot.unitOpenAmount * unclosedQuantity,
                        currency: lot.openAmount.currency
                    ),
                    date: lot.date
                )
                lot.quantity -= unclosedQuantity
                lot.openAmount = Amount(
                    value: lot.openAmount.value - separatedLot.openAmount.value,
                    currency: lot.openAmount.currency
                )
                dataBase.insert(entity: separatedLot)
                closedLots.append(separatedLot)
                break
            } else {
                closedLots.append(lot)
                unclosedQuantity -= lot.quantity
                position.lots.removeAll(where: { $0.id == lot.id })
            }
        }

        let closedLotsOpenAmount = closedLots.reduce(0) { $0 + $1.openAmount.value }
        transaction.closedLots = closedLots
        transaction.profit = Amount(
            value: transaction.amount.value - closedLotsOpenAmount,
            currency: transaction.amount.currency
        )

        if position.lots.isEmpty {
            portfolio.positions.removeAll(where: {
                $0.asset.ticker == transaction.asset.ticker && $0.asset.exchange.code == transaction.asset.exchange.code
            })
            dataBase.delete(entity: position)
        }
    }

    private func validateAssetTransactions(in portfolio: PortfolioEntity, excluding transactionID: String) throws {
        let assetTransactions = (
            portfolio.buyAssetsTransactions
                .filter { $0.id != transactionID }
                .map(AssetTransactionEntity.buy) +
            portfolio.sellAssetsTransactions
                .filter { $0.id != transactionID }
                .map(AssetTransactionEntity.sell)
        ).sorted { lhs, rhs in
            if lhs.date == rhs.date {
                return lhs.sortPriority < rhs.sortPriority
            }
            return lhs.date < rhs.date
        }

        var quantities: [AssetKey: Double] = [:]

        for transaction in assetTransactions {
            guard transaction.quantity > 0, transaction.amount.value > 0 else {
                throw TransactionsErrors.notEnoughQuantity
            }

            let assetKey = transaction.assetKey
            switch transaction {
            case .buy:
                quantities[assetKey, default: 0] += transaction.quantity
            case .sell:
                guard quantities[assetKey, default: 0] >= transaction.quantity else {
                    throw TransactionsErrors.notEnoughQuantity
                }
                quantities[assetKey, default: 0] -= transaction.quantity
            }
        }
    }

    private func position(for asset: AssetEntity, in portfolio: PortfolioEntity) -> PositionEntity? {
        portfolio.positions.first {
            $0.asset.ticker == asset.ticker && $0.asset.exchange.code == asset.exchange.code
        }
    }

    private func createPosition(for asset: AssetEntity, in portfolio: PortfolioEntity) -> PositionEntity {
        let position = PositionEntity(asset: asset, lots: [], portfolio: portfolio)
        asset.positions.append(position)
        portfolio.positions.append(position)
        dataBase.insert(entity: position)
        return position
    }

    private func updateAmount(_ currentAmounts: [Amount], with amount: Amount) -> [Amount] {
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

//    private func updatePosition(
//        in portfolio: PortfolioEntity,
//        asset: AssetEntity,
//        type: AssetTransactionType,
//        quantity: Double,
//        amount: Amount
//    ) throws {
//        if let position = portfolio.positions.first(where: {
//            $0.asset.ticker == asset.ticker && $0.asset.exchange.code == asset.exchange.code
//        }) {
//            switch type {
//            case .buy:
//                position.quantity = position.quantity + quantity
//                position.openAmount = Amount(
//                    value: position.openAmount.value + amount.value,
//                    currency: amount.currency
//                )
//            case let .sell(profit):
//                position.quantity = max(0, position.quantity - quantity)
//                position.openAmount = Amount(
//                    value: max(0, position.openAmount.value - (amount.value - profit.value)),
//                    currency: amount.currency
//                )
//            }
//
//            return
//        }
//
//        guard type == .buy else {
//            throw TransactionsErrors.nothingToSell
//        }
//
//        let newPosition = PositionEntity(
//            asset: asset,
//            quantity: quantity,
//            openAmount: amount,
//            portfolio: portfolio
//        )
//        asset.positions.append(newPosition)
//        portfolio.positions.append(newPosition)
//        
//        dataBase.insert(entity: newPosition)
//    }
}

private struct AssetKey: Hashable {
    let ticker: String
    let exchangeCode: String
}

private enum AssetTransactionEntity {
    case buy(BuyAssetTransactionEntity)
    case sell(SellAssetTransactionEntity)

    var assetKey: AssetKey {
        switch self {
        case let .buy(transaction):
            AssetKey(ticker: transaction.asset.ticker, exchangeCode: transaction.asset.exchange.code)
        case let .sell(transaction):
            AssetKey(ticker: transaction.asset.ticker, exchangeCode: transaction.asset.exchange.code)
        }
    }

    var date: Date {
        switch self {
        case let .buy(transaction):
            transaction.date
        case let .sell(transaction):
            transaction.date
        }
    }

    var quantity: Double {
        switch self {
        case let .buy(transaction):
            transaction.quantity
        case let .sell(transaction):
            transaction.quantity
        }
    }

    var amount: Amount {
        switch self {
        case let .buy(transaction):
            transaction.amount
        case let .sell(transaction):
            transaction.amount
        }
    }

    var sortPriority: Int {
        switch self {
        case .buy:
            0
        case .sell:
            1
        }
    }
}

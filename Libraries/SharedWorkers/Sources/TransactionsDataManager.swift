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
}

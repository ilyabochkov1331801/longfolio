//
//  CreateCashTransactionScreenViewModel.swift
//  longfolio
//
//  Created by Assistant on 07.04.26.
//

import Foundation
import SharedModels
import SharedWorkers

@Observable
final class CreateCashTransactionScreenViewModel {
    private let transactionsDataManager: ManagesTransactionsData

    let portfolioName: String
    var selectedCurrency: Currency = .usd
    var amountValue: Double = 0
    var date: Date = .now
    var error: String?

    var canSave: Bool {
        amountValue != 0
    }

    init(dependencyContainer: DIContainer, portfolio: Portfolio) {
        let dataBase = SwiftDataBase(contextManager: dependencyContainer.contextManager)
        self.transactionsDataManager = TransactionsDataManager(dataBase: dataBase)
        self.portfolioName = portfolio.name
    }
}

@MainActor
extension CreateCashTransactionScreenViewModel {
    func createCashTransaction() -> Bool {
        do {
            try transactionsDataManager.createCashTransaction(
                for: portfolioName,
                amount: Amount(value: amountValue, currency: selectedCurrency),
                date: date
            )
            return true
        } catch {
            self.error = error.localizedDescription
            return false
        }
    }
}

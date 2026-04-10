//
//  CreateDividendTransactionScreenViewModel.swift
//  longfolio
//
//  Created by Assistant on 08.04.26.
//

import Foundation
import SharedModels
import SharedWorkers

@Observable
final class CreateDividendTransactionScreenViewModel {
    private let transactionsDataManager: ManagesTransactionsData

    let portfolioName: String
    let positions: [Position]
    var selectedTicker: AssetTicker?
    var amountValue: Double = 0
    var date: Date = .now
    var error: String?

    var canSave: Bool {
        selectedTicker != nil && amountValue > 0
    }

    init(dependencyContainer: DIContainer, portfolio: Portfolio) {
        let dataBase = SwiftDataBase(contextManager: dependencyContainer.contextManager)
        self.transactionsDataManager = TransactionsDataManager(dataBase: dataBase)
        self.portfolioName = portfolio.name
        self.positions = portfolio.positions
        self.selectedTicker = portfolio.positions.first?.ticker
    }
}

@MainActor
extension CreateDividendTransactionScreenViewModel {
    func createDividendTransaction() -> Bool {
        guard
            let selectedTicker,
            let selectedPosition = positions.first(where: { $0.ticker == selectedTicker })
        else {
            return false
        }

        do {
            try transactionsDataManager.createDividendTransaction(
                for: portfolioName,
                asset: selectedTicker,
                quantity: selectedPosition.quantity,
                amount: Amount(
                    value: amountValue,
                    currency: selectedTicker.exchange.currency
                ),
                date: date
            )
            return true
        } catch {
            self.error = error.localizedDescription
            return false
        }
    }
}

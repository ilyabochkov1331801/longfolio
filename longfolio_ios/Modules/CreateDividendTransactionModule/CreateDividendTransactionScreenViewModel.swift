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
    var selectedAsset: Asset?
    var amountValue: Double = 0
    var date: Date = .now
    var error: String?

    var canSave: Bool {
        selectedAsset != nil && amountValue > 0
    }

    init(dependencyContainer: DIContainer, portfolio: Portfolio) {
        let dataBase = SwiftDataBase(contextManager: dependencyContainer.contextManager)
        self.transactionsDataManager = TransactionsDataManager(dataBase: dataBase)
        self.portfolioName = portfolio.name
        self.positions = portfolio.positions
        self.selectedAsset = portfolio.positions.first?.asset
    }
}

@MainActor
extension CreateDividendTransactionScreenViewModel {
    func createDividendTransaction() -> Bool {
        guard let selectedAsset = selectedAsset else { return false }

        do {
            try transactionsDataManager.createDividendTransaction(
                for: portfolioName,
                asset: selectedAsset,
                amount: Amount(
                    value: amountValue,
                    currency: selectedAsset.currency
                ),
                paidTaxes: Amount( // TOOD: Добавить учет налога
                    value: 0,
                    currency: selectedAsset.currency
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

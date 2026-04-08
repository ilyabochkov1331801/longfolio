//
//  CreateCashTransactionScreenViewModel.swift
//  longfolio
//
//  Created by Assistant on 07.04.26.
//

import Foundation
import SharedModels
import SharedWorkers

struct CreateCashTransactionScreenModel: Equatable {
    let portfolioName: String
    let selectedCurrency: Currency
    let amountValue: Double
    let date: Date
    let canSave: Bool
}

@Observable
final class CreateCashTransactionScreenViewModel {
    var state: ScreenViewState<CreateCashTransactionScreenModel>

    private let transactionsDataManager: ManagesTransactionsData

    init(dependencyContainer: DIContainer, portfolio: Portfolio) {
        let dataBase = SwiftDataBase(contextManager: dependencyContainer.contextManager)
        self.transactionsDataManager = TransactionsDataManager(dataBase: dataBase)
        self.state = .normal(
            CreateCashTransactionScreenModel(
                portfolioName: portfolio.name,
                selectedCurrency: .usd,
                amountValue: 0,
                date: .now,
                canSave: false
            )
        )
    }
}

@MainActor
extension CreateCashTransactionScreenViewModel {
    func updateCurrency(_ currency: Currency, with model: CreateCashTransactionScreenModel) {
        state = .normal(
            CreateCashTransactionScreenModel(
                portfolioName: model.portfolioName,
                selectedCurrency: currency,
                amountValue: model.amountValue,
                date: model.date,
                canSave: model.canSave
            )
        )
    }

    func updateAmountValue(_ amountValue: Double, with model: CreateCashTransactionScreenModel) {
        state = .normal(
            CreateCashTransactionScreenModel(
                portfolioName: model.portfolioName,
                selectedCurrency: model.selectedCurrency,
                amountValue: amountValue,
                date: model.date,
                canSave: canSave(amountValue: amountValue)
            )
        )
    }

    func updateDate(_ date: Date, with model: CreateCashTransactionScreenModel) {
        state = .normal(
            CreateCashTransactionScreenModel(
                portfolioName: model.portfolioName,
                selectedCurrency: model.selectedCurrency,
                amountValue: model.amountValue,
                date: date,
                canSave: model.canSave
            )
        )
    }

    func createCashTransaction(with model: CreateCashTransactionScreenModel) -> Bool {
        do {
            try transactionsDataManager.createCashTransaction(
                for: model.portfolioName,
                amount: Amount(value: model.amountValue, currency: model.selectedCurrency),
                date: model.date
            )
            return true
        } catch {
            state = .error(error)
            return false
        }
    }

    private func canSave(amountValue: Double) -> Bool {
        amountValue != 0
    }
}

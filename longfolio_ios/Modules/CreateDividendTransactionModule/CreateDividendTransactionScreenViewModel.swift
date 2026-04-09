//
//  CreateDividendTransactionScreenViewModel.swift
//  longfolio
//
//  Created by Assistant on 08.04.26.
//

import Foundation
import SharedModels
import SharedWorkers

struct CreateDividendTransactionScreenModel: Equatable {
    let portfolioName: String
    let positions: [Position]
    let selectedTicker: AssetTicker?
    let amountValue: Double
    let date: Date
    let canSave: Bool
}

@Observable
final class CreateDividendTransactionScreenViewModel {
    var state: ScreenViewState<CreateDividendTransactionScreenModel>

    private let transactionsDataManager: ManagesTransactionsData

    init(dependencyContainer: DIContainer, portfolio: Portfolio) {
        let dataBase = SwiftDataBase(contextManager: dependencyContainer.contextManager)
        self.transactionsDataManager = TransactionsDataManager(dataBase: dataBase)
        self.state = .normal(
            CreateDividendTransactionScreenModel(
                portfolioName: portfolio.name,
                positions: portfolio.positions,
                selectedTicker: portfolio.positions.first?.ticker,
                amountValue: 0,
                date: .now,
                canSave: false
            )
        )
    }
}

@MainActor
extension CreateDividendTransactionScreenViewModel {
    func updateTicker(_ ticker: AssetTicker, with model: CreateDividendTransactionScreenModel) {
        state = .normal(
            CreateDividendTransactionScreenModel(
                portfolioName: model.portfolioName,
                positions: model.positions,
                selectedTicker: ticker,
                amountValue: model.amountValue,
                date: model.date,
                canSave: canSave(selectedTicker: ticker, amountValue: model.amountValue)
            )
        )
    }

    func updateAmountValue(_ amountValue: Double, with model: CreateDividendTransactionScreenModel) {
        state = .normal(
            CreateDividendTransactionScreenModel(
                portfolioName: model.portfolioName,
                positions: model.positions,
                selectedTicker: model.selectedTicker,
                amountValue: amountValue,
                date: model.date,
                canSave: canSave(selectedTicker: model.selectedTicker, amountValue: amountValue)
            )
        )
    }

    func updateDate(_ date: Date, with model: CreateDividendTransactionScreenModel) {
        state = .normal(
            CreateDividendTransactionScreenModel(
                portfolioName: model.portfolioName,
                positions: model.positions,
                selectedTicker: model.selectedTicker,
                amountValue: model.amountValue,
                date: date,
                canSave: model.canSave
            )
        )
    }

    func createDividendTransaction(with model: CreateDividendTransactionScreenModel) -> Bool {
        guard
            let selectedTicker = model.selectedTicker,
            let selectedPosition = model.positions.first(where: { $0.ticker == selectedTicker })
        else {
            return false
        }

        do {
            try transactionsDataManager.createDividendTransaction(
                for: model.portfolioName,
                asset: selectedTicker,
                quantity: selectedPosition.quantity,
                amount: Amount(
                    value: model.amountValue,
                    currency: selectedTicker.exchange.currency
                ),
                date: model.date
            )
            return true
        } catch {
            state = .error(error)
            return false
        }
    }

    private func canSave(selectedTicker: AssetTicker?, amountValue: Double) -> Bool {
        selectedTicker != nil && amountValue > 0
    }
}

//
//  TransactionsScreenViewModel.swift
//  longfolio
//
//  Created by Assistant on 08.04.26.
//

import Foundation
import Combine
import SharedModels
import SharedWorkers

@Observable
final class TransactionsScreenViewModel {
    private let portfolioName: String
    private let reloadsFromStorage: Bool
    private let portfolioDataManager: ManagesPortfolioData
    private let transactionsDataManager: ManagesTransactionsData
    private let contextManager: ManagesSwiftDataContext
    private var cancelBag: Set<AnyCancellable> = []

    var portfolio: Portfolio
    var error: String?
    var canEditTransactions: Bool {
        reloadsFromStorage
    }

    init(
        dependencyContainer: DIContainer,
        portfolio: Portfolio,
        reloadsFromStorage: Bool = true
    ) {
        self.portfolioName = portfolio.name
        self.reloadsFromStorage = reloadsFromStorage
        self.contextManager = dependencyContainer.contextManager
        let dataBase = SwiftDataBase(contextManager: dependencyContainer.contextManager)
        self.portfolioDataManager = PortfolioDataManager(dataBase: dataBase)
        self.transactionsDataManager = TransactionsDataManager(dataBase: dataBase)
        self.portfolio = portfolio
        setupBindings()
    }
}

@MainActor
extension TransactionsScreenViewModel {
    func setupBindings() {
        contextManager.updatesPublisher
            .sink { [weak self] _ in
                self?.loadTransactions()
            }
            .store(in: &cancelBag)
    }

    func loadTransactions() {
        guard reloadsFromStorage else {
            return
        }

        do {
            guard let portfolio = try portfolioDataManager.fetchPortfolio(with: portfolioName) else {
                return
            }

            self.portfolio = portfolio
            error = nil
        } catch {
            self.error = error.localizedDescription
        }
    }

    func updateCashTransactionDate(id: String, date: Date) -> Bool {
        do {
            try transactionsDataManager.updateCashTransactionDate(id: id, date: date)
            loadTransactions()
            return true
        } catch {
            self.error = error.localizedDescription
            return false
        }
    }

    func updateDividendTransactionDate(id: String, date: Date) -> Bool {
        do {
            try transactionsDataManager.updateDividendTransactionDate(id: id, date: date)
            loadTransactions()
            return true
        } catch {
            self.error = error.localizedDescription
            return false
        }
    }

    func updateAssetTransactionDate(id: String, isSell: Bool, date: Date) -> Bool {
        do {
            try transactionsDataManager.updateAssetTransactionDate(id: id, isSell: isSell, date: date)
            loadTransactions()
            return true
        } catch {
            self.error = error.localizedDescription
            return false
        }
    }

    func updateCashTransaction(id: String, amount: Amount, date: Date) -> Bool {
        do {
            try transactionsDataManager.updateCashTransaction(id: id, amount: amount, date: date)
            loadTransactions()
            return true
        } catch {
            self.error = error.localizedDescription
            return false
        }
    }

    func updateDividendTransaction(id: String, asset: Asset, amount: Amount, paidTaxes: Amount, date: Date) -> Bool {
        do {
            try transactionsDataManager.updateDividendTransaction(
                id: id,
                asset: asset,
                amount: amount,
                paidTaxes: paidTaxes,
                date: date
            )
            loadTransactions()
            return true
        } catch {
            self.error = error.localizedDescription
            return false
        }
    }

    func updateBuyAssetTransaction(
        id: String,
        asset: Asset,
        quantity: Double,
        amount: Amount,
        commision: Amount,
        date: Date
    ) -> Bool {
        do {
            try transactionsDataManager.updateBuyAssetTransaction(
                id: id,
                asset: asset,
                quantity: quantity,
                amount: amount,
                commision: commision,
                date: date
            )
            loadTransactions()
            return true
        } catch {
            self.error = message(for: error)
            return false
        }
    }

    func updateSellAssetTransaction(
        id: String,
        asset: Asset,
        quantity: Double,
        amount: Amount,
        commision: Amount,
        date: Date
    ) -> Bool {
        do {
            try transactionsDataManager.updateSellAssetTransaction(
                id: id,
                asset: asset,
                quantity: quantity,
                amount: amount,
                commision: commision,
                date: date
            )
            loadTransactions()
            return true
        } catch {
            self.error = message(for: error)
            return false
        }
    }

    func deleteCashTransaction(id: String) -> Bool {
        do {
            try transactionsDataManager.deleteCashTransaction(id: id)
            loadTransactions()
            return true
        } catch {
            self.error = error.localizedDescription
            return false
        }
    }

    func deleteDividendTransaction(id: String) -> Bool {
        do {
            try transactionsDataManager.deleteDividendTransaction(id: id)
            loadTransactions()
            return true
        } catch {
            self.error = error.localizedDescription
            return false
        }
    }

    func deleteAssetTransaction(id: String, isSell: Bool) -> Bool {
        do {
            try transactionsDataManager.deleteAssetTransaction(id: id, isSell: isSell)
            loadTransactions()
            return true
        } catch {
            self.error = message(for: error)
            return false
        }
    }

    private func message(for error: Error) -> String {
        if let error = error as? TransactionsErrors {
            switch error {
            case .nothingToSell:
                return "There is no open position for this asset on the selected date."
            case .notEnoughQuantity:
                return "Transaction history would sell more units than available."
            case .lotNotFound:
                return "Selected lot no longer exists."
            }
        }

        return error.localizedDescription
    }
}

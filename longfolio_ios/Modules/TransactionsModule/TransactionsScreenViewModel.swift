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
    private let contextManager: ManagesSwiftDataContext
    private var cancelBag: Set<AnyCancellable> = []

    var portfolio: Portfolio
    var error: String?

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
}

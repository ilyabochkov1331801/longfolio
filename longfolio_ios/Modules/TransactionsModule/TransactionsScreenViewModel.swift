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

struct TransactionsScreenModel: Equatable {
    let portfolio: Portfolio
}

@Observable
final class TransactionsScreenViewModel {
    var state: ScreenViewState<TransactionsScreenModel>

    private let portfolioName: String
    private let portfolioDataManager: ManagesPortfolioData
    private let contextManager: ManagesSwiftDataContext
    private var cancelBag: Set<AnyCancellable> = []

    init(dependencyContainer: DIContainer, portfolio: Portfolio) {
        self.portfolioName = portfolio.name
        self.contextManager = dependencyContainer.contextManager
        let dataBase = SwiftDataBase(contextManager: dependencyContainer.contextManager)
        self.portfolioDataManager = PortfolioDataManager(dataBase: dataBase)
        self.state = .normal(TransactionsScreenModel(portfolio: portfolio))
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
        do {
            guard let portfolio = try portfolioDataManager.fetchPortfolio(with: portfolioName) else {
                return
            }

            state = .normal(TransactionsScreenModel(portfolio: portfolio))
        } catch {
            state = .error(error)
        }
    }
}

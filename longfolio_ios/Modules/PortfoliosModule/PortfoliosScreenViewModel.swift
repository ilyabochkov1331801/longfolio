//
//  PortfoliosScrenViewModel.swift
//  longfolio
//
//  Created by Илья Бочков on 2.04.26.
//

import Foundation
import Combine
import SharedModels
import SharedWorkers

struct PortfoliosScreenModel: Equatable {
    let portfolios: [Portfolio]
}

@Observable
final class PortfoliosScreenViewModel {
    var state: ScreenViewState<PortfoliosScreenModel> = .loading
    private let portfolioDataManager: ManagesPortfolioData
    private let contextManager: ManagesSwiftDataContext
    private var cancelBag: Set<AnyCancellable> = []

    init(dependencyContainer: DIContainer) {
        self.contextManager = dependencyContainer.contextManager
        let dataBase = SwiftDataBase(contextManager: dependencyContainer.contextManager)
        self.portfolioDataManager = PortfolioDataManager(dataBase: dataBase)
        setupBindings()
    }
}

@MainActor
extension PortfoliosScreenViewModel {
    func setupBindings() {
        contextManager.updatesPublisher
        .sink { [weak self] notification in
            self?.loadPortfolios()
        }
        .store(in: &cancelBag)
    }

    func loadPortfolios() {
        do {
            let portfolios = try portfolioDataManager.fetchPortfolios()
            state = .normal(PortfoliosScreenModel(portfolios: portfolios))
        } catch {
            state = .error(error)
        }
    }

    func deletePortfolio(with name: String) {
        do {
            try portfolioDataManager.deletePortfolio(with: name)
        } catch {
            state = .error(error)
        }
    }
}

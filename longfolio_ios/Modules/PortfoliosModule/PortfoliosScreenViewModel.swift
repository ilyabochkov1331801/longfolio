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

@Observable
final class PortfoliosScreenViewModel {
    private let portfolioDataManager: ManagesPortfolioData
    private let contextManager: ManagesSwiftDataContext
    private var cancelBag: Set<AnyCancellable> = []
    
    var portfolios: [Portfolio] = []
    var error: String?

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
            portfolios = try portfolioDataManager.fetchPortfolios()
        } catch {
            self.error = error.localizedDescription
        }
    }

    func deletePortfolio(with name: String) {
        do {
            try portfolioDataManager.deletePortfolio(with: name)
        } catch {
            
        }
    }
}

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
    private let contextManager: ManagesSwiftDataContext

    private let portfolioDataManager: ManagesPortfolioData
    private let realtimePricesProvider: ProvidesRealtimePrices
    private let portfolioStatisticsManager: PortfolioStatisticsDataManager

    private var cancelBag: Set<AnyCancellable> = []
    
    var portfolios: [Portfolio] = []
    var amounts: [String: [Amount]] = [:]
    var profits: [String: [Amount]] = [:]
    var totalAmount: [Amount]?
    
    init(dependencyContainer: DIContainer) {
        self.contextManager = dependencyContainer.contextManager
        let dataBase = SwiftDataBase(contextManager: dependencyContainer.contextManager)
        self.portfolioDataManager = PortfolioDataManager(dataBase: dataBase)
        
        self.realtimePricesProvider = RealtimePricesProvider(
            eodhdNetworkService: dependencyContainer.eodhdNetworkService,
            cache: dependencyContainer.realtimePriceCache
        )
        
        self.portfolioStatisticsManager = PortfolioStatisticsDataManager(
            realtimePricesProvider: realtimePricesProvider
        )
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
            loadAmounts()
        } catch {
            
        }
    }

    func deletePortfolio(with name: String) {
        do {
            try portfolioDataManager.deletePortfolio(with: name)
        } catch {
            
        }
    }
    
    private func loadAmounts() {
        Task {
            do {
                for portfolio in portfolios {
                    amounts[portfolio.name] = try await portfolioStatisticsManager.totalAmount(in: portfolio)
                    profits[portfolio.name] = try await portfolioStatisticsManager.openPositionsProfit(in: portfolio)
                }
                totalAmount = AmountCalculator.sum(of: amounts.values.flatMap { $0 })
            } catch {
                
            }
        }
    }
}

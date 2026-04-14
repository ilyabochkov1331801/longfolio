//
//  PortfolioDetailsScreenViewModel.swift
//  longfolio
//
//  Created by Assistant on 06.04.26.
//

import Foundation
import Combine
import SharedModels
import SharedWorkers
import Observation

@Observable
final class PortfolioDetailsScreenViewModel {
    private let portfolioDataManager: ManagesPortfolioData
    private let realtimePricesProvider: ProvidesRealtimePrices
    private let portfolioStatisticsManager: PortfolioStatisticsDataManager
    private let contextManager: ManagesSwiftDataContext
    private var cancelBag: Set<AnyCancellable> = []
    
    var totalAmount: [Amount]?
    var portfolio: Portfolio

    init(dependencyContainer: DIContainer, portfolio: Portfolio) {
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
        
        self.portfolio = portfolio
        
        setupBindings()
    }
}

@MainActor
extension PortfolioDetailsScreenViewModel {
    func setupBindings() {
        contextManager.updatesPublisher
            .sink { [weak self] _ in
                Task { await self?.loadPortfolio() }
            }
            .store(in: &cancelBag)
    }

    func loadPortfolio() async {
        do {
            guard let portfolio = try portfolioDataManager.fetchPortfolio(with: portfolio.name) else {
                return
            }

            self.portfolio = portfolio
            await loadPortfolioPrice()
        } catch {
            
        }
    }
    
    func loadPortfolioPrice() async {
        do {
            totalAmount = try await portfolioStatisticsManager.totalAmount(in: portfolio)
        } catch {

        }
    }
}

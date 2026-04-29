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
    var profitAmount: [Amount]?
    var portfolio: Portfolio
    
    var positionsForDisplaying: [Position] = []
    var positionsAmount: [Asset: Amount] = [:]
    var positionsProfit: [Asset: Amount] = [:]
    var canShowMorePositions = false

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
        positionsForDisplaying = Array(portfolio.positions.prefix(5))
        canShowMorePositions = portfolio.positions.count > 2
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
            positionsForDisplaying = Array(portfolio.positions.prefix(2))
            canShowMorePositions = portfolio.positions.count > 2
            await loadAmounts()
        } catch {
            
        }
    }
    
    func loadAmounts() async {
        do {
            totalAmount = try await portfolioStatisticsManager.totalAmount(in: portfolio)
            profitAmount = try await portfolioStatisticsManager.openPositionsProfit(in: portfolio)
            
            for position in portfolio.positions {
                let price = try await realtimePricesProvider.realtimePrice(for: position)
                //let positionOpenAmount = AmountCalculator.sum(of: position.lots.map(\.openAmount))
                //let profit = Amount(value: price.value - positionOpenAmount.value, currency: price.currency)
                
                positionsAmount[position.asset] = price
                positionsProfit[position.asset] = Amount(value: 0, currency: .eur)
            }
        } catch {

        }
    }
}

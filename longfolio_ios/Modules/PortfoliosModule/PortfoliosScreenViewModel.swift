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
    private let settingsProvider: ProvidesSettings
    private let currencyProvider: ProvidesCurrency

    private var cancelBag: Set<AnyCancellable> = []
    
    var portfolios: [Portfolio] = []
    var amounts: [String: [Amount]] = [:]
    var profits: [String: [Amount]] = [:]
    var convertedAmounts: [String: [Double]] = [:]
    var totalAmount: [Amount]?
    var convertedTotalAmount: Double = 0.0
    var defaultCurrency: Currency = .unknown
    
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
        
        self.settingsProvider = SettingsProvider(userDefaultsManager: dependencyContainer.userDefaultsManager)
        self.currencyProvider = CurrencyProvider(eodhdNetworkService: dependencyContainer.eodhdNetworkService)
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
    
    func convertAmount() {
        Task {
            do {
                let defaultCurrency = try settingsProvider.getDefaultCurrency()
                self.defaultCurrency = defaultCurrency
                convertedTotalAmount = try await currencyProvider.convert(to: defaultCurrency, amount: totalAmount ?? [])
            } catch {
                
            }
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
                convertAmount()
            } catch {
                
            }
        }
    }
}

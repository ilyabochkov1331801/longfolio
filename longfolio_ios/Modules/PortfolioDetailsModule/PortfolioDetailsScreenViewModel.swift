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
    private let portfolioName: String
    private let portfolioDataManager: ManagesPortfolioData
    private let realtimeAssetPriceProvider: ProvidesRealtimeAssetPrices
    private let contextManager: ManagesSwiftDataContext
    private var cancelBag: Set<AnyCancellable> = []
    
    var portfolioPrice: [Amount] = []
    var portfolio: Portfolio
    var error: String?

    init(dependencyContainer: DIContainer, portfolio: Portfolio) {
        self.portfolioName = portfolio.name
        self.contextManager = dependencyContainer.contextManager
        let dataBase = SwiftDataBase(contextManager: dependencyContainer.contextManager)
        self.portfolioDataManager = PortfolioDataManager(dataBase: dataBase)
        self.realtimeAssetPriceProvider = RealtimePriceProvider(eodhdNetworkService: dependencyContainer.eodhdNetworkService)
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
            guard let portfolio = try portfolioDataManager.fetchPortfolio(with: portfolioName) else {
                return
            }

            self.portfolio = portfolio
            await loadPortfolioPrice()
            error = nil
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    func loadPortfolioPrice() async {
        do {
            portfolioPrice = try await realtimeAssetPriceProvider.currentPrice(for: portfolio)
        } catch {
            self.error = error.localizedDescription
        }
    }
}

//
//  SearchAssetsForTransactionScreenViewModel.swift
//  longfolio
//
//  Created by Assistant on 08.04.26.
//

import Foundation
import SharedModels
import SharedNetwork
import SharedWorkers

@Observable
final class SearchAssetsForTransactionScreenViewModel {
    var tickerQuery: String = "" {
        didSet {
            guard oldValue != tickerQuery else { return }
            searchTask?.cancel()
            searchTask = Task {
                try? await Task.sleep(for: .milliseconds(350))
                guard !Task.isCancelled else { return }
                await self.searchAssets(for: tickerQuery)
            }
        }
    }
    
    let portfolioName: String
    var displayedAssets: [Asset]
    var error: String?

    private let portfolio: Portfolio
    private let eodhdNetworkService: EodhdNetworkServiceProtocol
    private let assetsDataManager: ManagesAssetsData
    private var searchTask: Task<Void, Never>?

    init(dependencyContainer: DIContainer, portfolio: Portfolio) {
        let dataBase = SwiftDataBase(contextManager: dependencyContainer.contextManager)
        let assetsDataManager = AssetsDataManager(dataBase: dataBase)
        self.portfolio = portfolio
        self.portfolioName = portfolio.name
        self.eodhdNetworkService = dependencyContainer.eodhdNetworkService
        self.assetsDataManager = assetsDataManager
        self.displayedAssets = portfolio.positions.compactMap { try? assetsDataManager.fetchAsset(for: $0.ticker) }
    }
}

@MainActor
extension SearchAssetsForTransactionScreenViewModel {
    var isSearching: Bool {
        !tickerQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func emptyStateDescription() -> String {
        if isSearching {
            return "Try another ticker or exchange."
        }

        return "Assets from the portfolio will appear here."
    }

    private func searchAssets(for query: String) async {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedQuery.isEmpty else {
            displayedAssets = portfolio.positions.compactMap { try? assetsDataManager.fetchAsset(for: $0.ticker) }
            error = nil
            return
        }

        do {
            let assets = try await eodhdNetworkService.searchAssets(for: trimmedQuery)
            let displayedAssets = assets.map(makeAsset)

            guard !Task.isCancelled, trimmedQuery == tickerQuery.trimmingCharacters(in: .whitespacesAndNewlines) else {
                return
            }

            error = nil
            self.displayedAssets = displayedAssets
        } catch {
            guard !Task.isCancelled else { return }
            self.error = error.localizedDescription
        }
    }

    private func makeAsset(from asset: EodhdAsset) -> Asset {
        let currency = Currency(rawValue: asset.currency.lowercased()) ?? .usd
        return Asset(
            ticker: AssetTicker(
                ticker: asset.code,
                exchange: Exchange(
                    name: asset.exchange,
                    code: asset.exchange,
                    country: asset.country,
                    currency: currency
                )
            ),
            currency: currency,
            priceHistory: [
                AssetDayPrice(
                    date: asset.previousCloseDate,
                    price: Amount(value: asset.previousClose, currency: currency)
                )
            ]
        )
    }
}

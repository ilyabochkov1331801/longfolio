//
//  CreateAssetTransactionDetailsScreenViewModel.swift
//  longfolio
//
//  Created by Assistant on 08.04.26.
//

import Foundation
import SharedModels
import SharedWorkers

@Observable
final class CreateAssetTransactionDetailsScreenViewModel {
    private let assetsDataManager: ManagesAssetsData
    private let transactionsDataManager: ManagesTransactionsData
    private let realtimePricesProvider: ProvidesRealtimePrices
    private let portfolioName: String

    let asset: Asset
    var currentPrice: Amount?
    var type: AssetTransactionType = .buy
    var date: Date = .now
    var amount: Double = 0
    var quantity: Double = 0
    var profite: Double = 0
    var error: String?

    var canSave: Bool {
        amount > 0 && quantity > 0
    }

    init(dependencyContainer: DIContainer, portfolioName: String, asset: Asset) {
        let dataBase = SwiftDataBase(contextManager: dependencyContainer.contextManager)
        self.assetsDataManager = AssetsDataManager(dataBase: dataBase)
        self.transactionsDataManager = TransactionsDataManager(dataBase: dataBase)
        self.portfolioName = portfolioName
        self.asset = asset
        self.realtimePricesProvider = RealtimePricesProvider(
            eodhdNetworkService: dependencyContainer.eodhdNetworkService,
            cache: dependencyContainer.realtimePriceCache
        )
    }
}

@MainActor
extension CreateAssetTransactionDetailsScreenViewModel {
    func loadCurrentPrice() async {
        do {
            currentPrice = try await realtimePricesProvider.realtimePrice(for: asset)
        } catch {
            
        }
    }
    
    func createTransaction() -> Bool {
        guard canSave else { return false }

        do {
            let asset = try assetsDataManager.saveAsset(asset)
            switch type {
            case .buy:
                try transactionsDataManager.createBuyAssetTransaction(
                    for: portfolioName,
                    asset: asset,
                    quantity: quantity,
                    amount: Amount(value: amount, currency: asset.currency),
                    commision: Amount(value: 0, currency: asset.currency), // TODO: Добавить комиссии
                    date: date
                )
                return true
            case .sell:
                try transactionsDataManager.createSellAssetTransaction(
                    for: portfolioName,
                    asset: asset,
                    quantity: quantity,
                    amount: Amount(value: amount, currency: asset.currency),
                    commision: Amount(value: 0, currency: asset.currency), // TODO: Добавить комиссии
                    date: date
                )
                return true
            }
            
        } catch {
            self.error = error.localizedDescription
            return false
        }
    }
}

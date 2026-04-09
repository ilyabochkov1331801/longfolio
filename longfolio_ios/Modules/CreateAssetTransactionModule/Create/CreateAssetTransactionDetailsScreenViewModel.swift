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
    private let portfolioName: String

    let asset: Asset
    var type: AssetTransactionType = .buy
    var date: Date = .now
    var amount: Double = 0
    var quantity: Double = 0
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
    }
}

@MainActor
extension CreateAssetTransactionDetailsScreenViewModel {
    func createTransaction() -> Bool {
        guard canSave else { return false }

        do {
            let asset = try assetsDataManager.saveAsset(asset)
            try transactionsDataManager.createAssetTransaction(
                for: portfolioName,
                asset: asset.ticker,
                type: type,
                quantity: quantity,
                amount: Amount(value: amount, currency: asset.currency),
                date: date
            )
            return true
        } catch {
            self.error = error.localizedDescription
            return false
        }
    }
}

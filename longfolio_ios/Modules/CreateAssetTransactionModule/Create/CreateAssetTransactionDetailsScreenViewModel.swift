//
//  CreateAssetTransactionDetailsScreenViewModel.swift
//  longfolio
//
//  Created by Assistant on 08.04.26.
//

import Foundation
import SharedModels
import SharedWorkers

struct CreateAssetTransactionDetailsScreenModel: Equatable {
    let asset: Asset
    let type: AssetTransactionType
    let date: Date
    let amount: Double
    let quantity: Double

    var canSave: Bool {
        amount > 0 && quantity > 0
    }
}

@Observable
final class CreateAssetTransactionDetailsScreenViewModel {
    var state: ScreenViewState<CreateAssetTransactionDetailsScreenModel>
    private let assetsDataManager: ManagesAssetsData
    private let transactionsDataManager: ManagesTransactionsData
    private let portfolioName: String

    init(dependencyContainer: DIContainer, portfolioName: String, asset: Asset) {
        let dataBase = SwiftDataBase(contextManager: dependencyContainer.contextManager)
        self.assetsDataManager = AssetsDataManager(dataBase: dataBase)
        self.transactionsDataManager = TransactionsDataManager(dataBase: dataBase)
        self.portfolioName = portfolioName
        self.state = .normal(
            CreateAssetTransactionDetailsScreenModel(
                asset: asset,
                type: .buy,
                date: .now,
                amount: 0,
                quantity: 0
            )
        )
    }
}

@MainActor
extension CreateAssetTransactionDetailsScreenViewModel {
    func updateType(_ type: AssetTransactionType, model: CreateAssetTransactionDetailsScreenModel) {
        state = .normal(
            CreateAssetTransactionDetailsScreenModel(
                asset: model.asset,
                type: type,
                date: model.date,
                amount: model.amount,
                quantity: model.quantity
            )
        )
    }

    func updateDate(_ date: Date, model: CreateAssetTransactionDetailsScreenModel) {
        state = .normal(
            CreateAssetTransactionDetailsScreenModel(
                asset: model.asset,
                type: model.type,
                date: date,
                amount: model.amount,
                quantity: model.quantity
            )
        )
    }

    func updateAmount(_ amount: Double, model: CreateAssetTransactionDetailsScreenModel) {
        state = .normal(
            CreateAssetTransactionDetailsScreenModel(
                asset: model.asset,
                type: model.type,
                date: model.date,
                amount: amount,
                quantity: model.quantity
            )
        )
    }

    func updateQuantity(_ quantity: Double, model: CreateAssetTransactionDetailsScreenModel) {
        state = .normal(
            CreateAssetTransactionDetailsScreenModel(
                asset: model.asset,
                type: model.type,
                date: model.date,
                amount: model.amount,
                quantity: quantity
            )
        )
    }

    func createTransaction(model: CreateAssetTransactionDetailsScreenModel) -> Bool {
        guard model.canSave else { return false }

        do {
            let asset = try assetsDataManager.saveAsset(model.asset)
            try transactionsDataManager.createAssetTransaction(
                for: portfolioName,
                asset: asset.ticker,
                type: model.type,
                quantity: model.quantity,
                amount: Amount(value: model.amount, currency: asset.currency),
                date: model.date
            )
            return true
        } catch {
            state = .error(error)
            return false
        }
    }
}

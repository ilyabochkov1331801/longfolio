//
//  SellAssetTransactionScreenViewModel.swift
//  longfolio
//
//  Created by Assistant on 30.05.26.
//

import Foundation
import SharedModels
import SharedWorkers

@Observable
final class SellAssetTransactionScreenViewModel {
    private let transactionsDataManager: ManagesTransactionsData
    private let realtimePricesProvider: ProvidesRealtimePrices
    private let portfolioName: String

    let lot: AssetLot
    let maximumQuantity: Double
    var currentPrice: Amount?
    var date: Date = .now
    var amount: Double = 0
    var commission: Double = 0
    var quantity: Double
    var error: String?

    var canSave: Bool {
        amount > 0 && quantity > 0 && quantity <= maximumQuantity
    }

    init(
        dependencyContainer: DIContainer,
        portfolioName: String,
        lot: AssetLot
    ) {
        let dataBase = SwiftDataBase(contextManager: dependencyContainer.contextManager)
        self.transactionsDataManager = TransactionsDataManager(dataBase: dataBase)
        self.realtimePricesProvider = RealtimePricesProvider(
            eodhdNetworkService: dependencyContainer.eodhdNetworkService,
            cache: dependencyContainer.realtimePriceCache
        )
        self.portfolioName = portfolioName
        self.lot = lot
        self.maximumQuantity = lot.quantity
        self.quantity = lot.quantity
    }

    var asset: Asset {
        lot.asset
    }
}

@MainActor
extension SellAssetTransactionScreenViewModel {
    func loadCurrentPrice() async {
        do {
            let price = try await realtimePricesProvider.realtimePrice(for: asset)
            currentPrice = price

            if amount == 0 {
                amount = price.value * quantity
            }
        } catch {

        }
    }

    func createTransaction() -> Bool {
        guard canSave else { return false }

        do {
            try transactionsDataManager.createSellAssetLotTransaction(
                for: portfolioName,
                lot: lot,
                quantity: quantity,
                amount: Amount(value: amount, currency: asset.currency),
                commision: Amount(value: commission, currency: asset.currency),
                date: date
            )
            return true
        } catch {
            if let error = error as? TransactionsErrors {
                switch error {
                case .nothingToSell:
                    self.error = "There is no open position for this asset."
                case .notEnoughQuantity:
                    self.error = "Not enough open lots to sell this quantity."
                case .lotNotFound:
                    self.error = "Selected lot no longer exists."
                }
            } else {
                self.error = error.localizedDescription
            }
            return false
        }
    }
}

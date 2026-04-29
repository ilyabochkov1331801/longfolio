//
//  AssetsDataManager.swift
//  SharedWorkers
//
//  Created by Assistant on 08.04.26.
//

import Foundation
import SharedModels
import SwiftData

@MainActor
public protocol ManagesAssetsData {
    func fetchAsset(for ticker: AssetTicker) throws -> Asset?
    func saveAsset(_ asset: Asset) throws -> Asset
}

public final class AssetsDataManager: ManagesAssetsData {
    private let dataBase: SwiftDataBaseProtocol
    private let mapper: SwiftDataModelsMapper

    public init(dataBase: SwiftDataBaseProtocol) {
        self.dataBase = dataBase
        self.mapper = SwiftDataModelsMapper()
    }

    public func fetchAsset(for ticker: AssetTicker) throws -> Asset? {
        let tickerCode = ticker.ticker
        let exchangeCode = ticker.exchange.code
        let descriptor = FetchDescriptor<AssetEntity>(
            predicate: #Predicate {
                $0.ticker == tickerCode && $0.exchange.code == exchangeCode
            }
        )

        return try dataBase.fetch(descriptor: descriptor).first.map(mapper.makeAsset)
    }

    public func saveAsset(_ asset: Asset) throws -> Asset {
        if let existingAsset = try fetchAsset(for: asset.ticker) {
            return existingAsset
        }

        let exchange = try fetchOrCreateExchange(from: asset.ticker.exchange)
        let assetEntity = AssetEntity(
            priceHistory: [],
            ticker: asset.ticker.ticker,
            currency: asset.currency,
            exchange: exchange,
            positions: []
        )
        dataBase.insert(entity: assetEntity)

        let priceHistory = asset.priceHistory.map { dayPrice in
            AssetDayPriceEntity(date: dayPrice.date, price: dayPrice.price, asset: assetEntity)
        }
        assetEntity.priceHistory = priceHistory
        priceHistory.forEach { dataBase.insert(entity: $0) }

        try dataBase.save()
        return asset
    }

    private func fetchOrCreateExchange(from exchange: Exchange) throws -> ExchangeEntity {
        let exchangeCode = exchange.code
        let descriptor = FetchDescriptor<ExchangeEntity>(
            predicate: #Predicate { $0.code == exchangeCode }
        )

        if let existingExchange = try dataBase.fetch(descriptor: descriptor).first {
            return existingExchange
        }

        let newExchange = ExchangeEntity(
            name: exchange.name,
            code: exchange.code,
            country: exchange.country,
            currency: exchange.currency,
            assets: []
        )
        dataBase.insert(entity: newExchange)
        return newExchange
    }
}

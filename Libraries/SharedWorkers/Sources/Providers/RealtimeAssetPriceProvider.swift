//
//  RealtimeAssetPriceProvider.swift
//  SharedWorkers
//
//  Created by Alena Nesterkina on 10.04.2026.
//

import Foundation
import SharedModels
import SharedNetwork

public protocol ProvidesRealtimeAssetPrices {
    func setCurrentPrice(for asset: Asset) async throws -> Asset
}

public final class RealtimeAssetPriceProvider: ProvidesRealtimeAssetPrices {
    private let eodhdNetworkService: EodhdNetworkServiceProtocol
    private let cache = PriceStore()
    
    public init(eodhdNetworkService: EodhdNetworkServiceProtocol) {
        self.eodhdNetworkService = eodhdNetworkService
    }
    
    public func setCurrentPrice(for asset: Asset) async throws -> Asset {
        let ticker = asset.ticker
        let exchange = asset.ticker.exchange
        
        if let cached = await cache.get(for: ticker) {
            return asset.with(currentPrice: cached)
        }
        
        if let pendingTask = await cache.getTask(for: ticker) {
            let result = try await pendingTask.value
            let amount = Amount(value: result.close, currency: asset.currency)
            return asset.with(currentPrice: amount)
        }

        let task = eodhdNetworkService.realTimeAssetPriceTask(for: ticker.ticker, exchange: exchange.code)
        await cache.setTask(for: ticker, task: task)
        let result = try await task.value
        let amount = Amount(value: result.close, currency: asset.currency)
        await cache.set(amount, for: ticker)
        await cache.removeTask(for: ticker)
        return asset.with(currentPrice: amount)
    }
}

actor PriceStore {
    private var storage: [AssetTicker: Amount] = [:]
    private var inFlight: [AssetTicker: Task<EodhdRealtimeAssetPrice, Error>] = [:]
    
    func setTask(for ticker: AssetTicker, task: Task<EodhdRealtimeAssetPrice, Error>) {
        inFlight[ticker] = task
    }
    
    func getTask(for ticker: AssetTicker) -> Task<EodhdRealtimeAssetPrice, Error>? {
        inFlight[ticker]
    }
    
    func removeTask(for ticker: AssetTicker) {
        inFlight[ticker] = nil
    }
    
    func get(for ticker: AssetTicker) -> Amount? {
        storage[ticker]
    }
    
    func set(_ price: Amount, for ticker: AssetTicker) {
        storage[ticker] = price
    }
}

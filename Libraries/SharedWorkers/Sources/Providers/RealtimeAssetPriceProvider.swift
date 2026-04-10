//
//  RealtimeAssetPriceProvider.swift
//  SharedWorkers
//
//  Created by Alena Nesterkina on 10.04.2026.
//

import Foundation
import SharedNetwork
import SharedModels

public protocol ManagesRealtimeAssetPrices {
    func fetchPrice(for ticker: AssetTicker) async throws -> Double
    func cachePrice(_ price: Double, for ticker: AssetTicker) async
}

public final class RealtimeAssetPriceProvider: ManagesRealtimeAssetPrices {
    private let eodhdNetworkService: EodhdNetworkServiceProtocol
    private let cache = PriceCache()
    
    public init(eodhdNetworkService: EodhdNetworkServiceProtocol) {
        self.eodhdNetworkService = eodhdNetworkService
    }
    
    public func fetchPrice(for ticker: AssetTicker) async throws -> Double {
        if let cached = await cache.get(for: ticker.ticker) {
            return cached
        }
        
        let assetPrice = try await eodhdNetworkService.realTimeAssetPrice(for: ticker.ticker, exchange: ticker.exchange.code)
        
        await cachePrice(assetPrice.close, for: ticker)
        return assetPrice.close
    }
    
    public func cachePrice(_ price: Double, for ticker: AssetTicker) async {
        await cache.set(price, for: ticker.ticker)
    }
}

actor PriceCache {
    private var storage: [String: Double] = [:]
    
    func get(for ticker: String) -> Double? {
        storage[ticker]
    }
    
    func set(_ price: Double, for ticker: String) {
        storage[ticker] = price
    }
}


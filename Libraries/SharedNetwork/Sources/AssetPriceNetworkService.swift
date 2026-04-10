// AssetPriceNetworkService.swift
// SharedWorkers
//
// Created by Assistant on 10.04.26.

import Foundation
import SharedModels

public protocol ManagesAssetPriceNetworking {
    func fetchRealTimePrice(for ticker: AssetTicker) async throws -> RealtimeAssetPrice
}

public final class AssetPriceNetworkService: ManagesAssetPriceNetworking {
    private let networkService: EodhdNetworkServiceProtocol
    
    public init(networkService: EodhdNetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    public func fetchRealTimePrice(for ticker: AssetTicker) async throws -> RealtimeAssetPrice {
        let assetPrice = try await networkService.realTimeAssetPrice(for: ticker.ticker, exchange: ticker.exchange.code)
        
        return RealtimeAssetPrice(ticker: ticker, close: assetPrice.close)
    }
}

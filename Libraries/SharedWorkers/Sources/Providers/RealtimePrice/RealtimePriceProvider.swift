//
//  RealtimeAssetPriceProvider.swift
//  SharedWorkers
//
//  Created by Alena Nesterkina on 10.04.2026.
//

import Foundation
import SharedModels
import SharedNetwork

public protocol ProvidesRealtimePrices {
    func realtimePrice(for asset: Asset) async throws -> Amount
    func realtimePrice(for position: Position) async throws -> Amount
    func positionsRealtimePrice(in portfolio: Portfolio) async throws -> [Amount]
}

@MainActor
public struct RealtimePricesProvider: ProvidesRealtimePrices {
    private let eodhdNetworkService: EodhdNetworkServiceProtocol
    private let cache: RealtimePriceCache
    
    public init(eodhdNetworkService: EodhdNetworkServiceProtocol, cache: RealtimePriceCache) {
        self.eodhdNetworkService = eodhdNetworkService
        self.cache = cache
    }
    
    public func realtimePrice(for asset: Asset) async throws -> Amount {
        let ticker = asset.ticker
        let exchange = asset.ticker.exchange
        
        if let cached = await cache.get(for: ticker) {
            return cached
        }
        
        if let pendingTask = await cache.getTask(for: ticker) {
            return try await pendingTask.value
        }

        let dataTask = eodhdNetworkService.realTimeAssetPriceTask(for: ticker.ticker, exchange: exchange.code)
        let task = Task {
            let closeValue = try await dataTask.value.close
            return Amount(value: closeValue, currency: asset.currency)
        }
        await cache.setTask(for: ticker, task: task)
        let amount = try await task.value
        await cache.set(amount, for: ticker)
        await cache.removeTask(for: ticker)
        return amount
    }
    
    public func realtimePrice(for position: Position) async throws -> Amount {
        let assetPrice = try await realtimePrice(for: position.asset)
        return Amount(value: assetPrice.value * position.quantity, currency: assetPrice.currency)
    }
    
    public func positionsRealtimePrice(in portfolio: Portfolio) async throws -> [Amount] {
        let positionPrices = try await withThrowingTaskGroup(of: Amount.self) { group in
            for position in portfolio.positions {
                group.addTask {
                    try await self.realtimePrice(for: position)
                }
            }
            
            var responses: [Amount] = []
            for try await result in group {
                responses.append(result)
            }
            return responses
        }
        
        return AmountCalculator.sum(of: positionPrices)
    }
}

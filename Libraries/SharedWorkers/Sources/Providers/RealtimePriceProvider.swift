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
    func currentPrice(for asset: Asset) async throws -> Amount
    func currentPrice(for position: Position) async throws -> Amount
    func currentPrice(for portfolio: Portfolio) async throws -> [Amount]
}

@MainActor
public final class RealtimePriceProvider: ProvidesRealtimeAssetPrices {
    private let eodhdNetworkService: EodhdNetworkServiceProtocol
    private let cache = PriceStore()
    
    public init(eodhdNetworkService: EodhdNetworkServiceProtocol) {
        self.eodhdNetworkService = eodhdNetworkService
    }
    
    public func currentPrice(for asset: Asset) async throws -> Amount {
        let ticker = asset.ticker
        let exchange = asset.ticker.exchange
        
        if let cached = await cache.get(for: ticker) {
            return cached
        }
        
        if let pendingTask = await cache.getTask(for: ticker) {
            let result = try await pendingTask.value
            let amount = Amount(value: result.close, currency: asset.currency)
            return amount
        }

        let task = eodhdNetworkService.realTimeAssetPriceTask(for: ticker.ticker, exchange: exchange.code)
        await cache.setTask(for: ticker, task: task)
        let result = try await task.value
        let amount = Amount(value: result.close, currency: asset.currency)
        await cache.set(amount, for: ticker)
        await cache.removeTask(for: ticker)
        return amount
    }
    
    public func currentPrice(for position: Position) async throws -> Amount {
        let assetPrice = try await currentPrice(for: position.asset)
        return Amount(value: assetPrice.value * position.quantity, currency: assetPrice.currency)
    }
    
    public func currentPrice(for portfolio: Portfolio) async throws -> [Amount] {
        let positionPrices = try await withThrowingTaskGroup(of: Amount.self) { group in
            for position in portfolio.positions {
                group.addTask { 
                    try await self.currentPrice(for: position)
                }
            }
            
            var responses: [Amount] = []
            for try await result in group {
                responses.append(result)
            }
            return responses
        }
        
        return Array(
            (positionPrices + portfolio.cashAmount).reduce(into: [Currency: Amount]()) { result, element in
                result[element.currency] = Amount(
                    value: (result[element.currency]?.value ?? 0) + element.value,
                    currency: element.currency
                )
            }.values
        )
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

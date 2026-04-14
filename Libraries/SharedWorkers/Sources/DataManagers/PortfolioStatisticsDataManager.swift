//
//  PortfolioStatisticsDataManager.swift
//  SharedWorkers
//
//  Created by Илья Бочков on 14.04.26.
//

import SharedModels

public struct PortfolioStatisticsDataManager {
    private let realtimePricesProvider: ProvidesRealtimePrices
    
    public init(realtimePricesProvider: ProvidesRealtimePrices) {
        self.realtimePricesProvider = realtimePricesProvider
    }
    
    public func totalAmount(in portfolio: Portfolio) async throws -> [Amount] {
        let positionsAmount = try await realtimePricesProvider.positionsRealtimePrice(in: portfolio)
        return AmountCalculator.sum(of: positionsAmount + portfolio.cashAmount)
    }
    
    public func openPositionsProfit(in portfolio: Portfolio) async throws -> [Amount] {
        let positionsAmount = try await realtimePricesProvider.positionsRealtimePrice(in: portfolio)
        let positionsHolding = portfolio.positions.map(\.openAmount)
        return AmountCalculator.difference(of: positionsAmount, taken: positionsHolding)
    }
}

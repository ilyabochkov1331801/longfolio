//
//  Snapshots.swift
//  SharedModels
//
//  Created by Alena Nesterkina on 24.03.26.
//

import Foundation

public struct PositionSnapshot: Equatable, Hashable, Sendable {
    public let ticker: AssetTicker
    public let quantity: Double
    public let price: Amount
    public let openAmount: Amount

    public init(ticker: AssetTicker, quantity: Double, price: Amount, openAmount: Amount) {
        self.ticker = ticker
        self.quantity = quantity
        self.price = price
        self.openAmount = openAmount
    }
}

public struct PortfolioSnapshot: Equatable, Hashable, Sendable {
    public let positions: [PositionSnapshot]
    public let date: Date
    public let name: String
    public let cache: [Amount]
    public let realizedProfit: [Amount]

    public init(
        positions: [PositionSnapshot],
        date: Date,
        name: String,
        cache: [Amount],
        realizedProfit: [Amount] = []
    ) {
        self.positions = positions
        self.date = date
        self.name = name
        self.cache = cache
        self.realizedProfit = realizedProfit
    }
}

public extension PortfolioSnapshot {
    static func combined(name: String, date: Date, snapshots: [PortfolioSnapshot]) -> PortfolioSnapshot {
        PortfolioSnapshot(
            positions: combinedPositions(from: snapshots.flatMap(\.positions)),
            date: date,
            name: name,
            cache: sum(snapshots.flatMap(\.cache)),
            realizedProfit: sum(snapshots.flatMap(\.realizedProfit))
        )
    }

    private static func combinedPositions(from positions: [PositionSnapshot]) -> [PositionSnapshot] {
        Dictionary(grouping: positions, by: \.ticker)
            .map { ticker, positions in
                PositionSnapshot(
                    ticker: ticker,
                    quantity: positions.reduce(0) { $0 + $1.quantity },
                    price: sumSingleCurrency(positions.map(\.price)),
                    openAmount: sumSingleCurrency(positions.map(\.openAmount))
                )
            }
            .sorted { $0.ticker.ticker < $1.ticker.ticker }
    }

    private static func sum(_ amounts: [Amount]) -> [Amount] {
        Array(
            amounts.reduce(into: [Currency: Amount]()) { result, amount in
                result[amount.currency] = Amount(
                    value: (result[amount.currency]?.value ?? 0) + amount.value,
                    currency: amount.currency
                )
            }.values
        )
    }

    private static func sumSingleCurrency(_ amounts: [Amount]) -> Amount {
        guard let firstAmount = amounts.first else {
            return Amount(value: 0, currency: .usd)
        }

        return Amount(
            value: amounts
                .filter { $0.currency == firstAmount.currency }
                .reduce(0) { $0 + $1.value },
            currency: firstAmount.currency
        )
    }
}

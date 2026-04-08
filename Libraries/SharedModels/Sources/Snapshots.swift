//
//  Snapshots.swift
//  SharedModels
//
//  Created by Alena Nesterkina on 24.03.26.
//

import Foundation

public struct PositionSnapshot: Equatable, Hashable  {
    public let ticker: AssetTicker
    public let quantity: Double
    public let price: Amount

    public init(ticker: AssetTicker, quantity: Double, price: Amount) {
        self.ticker = ticker
        self.quantity = quantity
        self.price = price
    }
}

public struct PortfolioSnapshot: Equatable, Hashable  {
    public let positions: [PositionSnapshot]
    public let date: Date
    public let name: String
    public let cache: [Amount]

    public init(positions: [PositionSnapshot], date: Date, name: String, cache: [Amount]) {
        self.positions = positions
        self.date = date
        self.name = name
        self.cache = cache
    }
}

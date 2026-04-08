//
//  Position.swift
//  SharedModels
//
//  Created by Alena Nesterkina on 24.03.26.
//

public struct Position: Equatable, Hashable  {
    public let ticker: AssetTicker
    public let quantity: Double
    public let averageOpenPrice: Amount

    public init(ticker: AssetTicker, quantity: Double, averageOpenPrice: Amount) {
        self.ticker = ticker
        self.quantity = quantity
        self.averageOpenPrice = averageOpenPrice
    }
}

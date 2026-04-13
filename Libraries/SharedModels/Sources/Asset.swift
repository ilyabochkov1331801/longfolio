//
//  Asset.swift
//  SharedModels
//
//  Created by Alena Nesterkina on 24.03.26.
//

import Foundation

public struct Asset: Equatable, Hashable {
    public let ticker: AssetTicker
    public let currency: Currency
    public let priceHistory: [AssetDayPrice]

    public init(ticker: AssetTicker, currency: Currency, priceHistory: [AssetDayPrice]) {
        self.ticker = ticker
        self.currency = currency
        self.priceHistory = priceHistory
    }
}

public struct AssetTicker: Equatable, Hashable, Sendable, Codable {
    public let ticker: String
    public let exchange: Exchange

    public init(ticker: String, exchange: Exchange) {
        self.ticker = ticker
        self.exchange = exchange
    }
}

public struct AssetDayPrice: Equatable, Hashable  {
    public let date: Date
    public let price: Amount

    public init(date: Date, price: Amount) {
        self.date = date
        self.price = price
    }
}

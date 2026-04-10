//
//  Asset.swift
//  SharedModels
//
//  Created by Alena Nesterkina on 24.03.26.
//

import Foundation

public struct Asset: Equatable, Hashable  {
    public let ticker: AssetTicker
    public let currency: Currency
    public let priceHistory: [AssetDayPrice]
    public let currentPrice: Amount?

    public init(ticker: AssetTicker, currency: Currency, priceHistory: [AssetDayPrice], currentPrice: Amount? = nil) {
        self.ticker = ticker
        self.currency = currency
        self.priceHistory = priceHistory
        self.currentPrice = currentPrice
    }
    
    public func with(currentPrice: Amount) -> Asset {
        Asset(
            ticker: ticker,
            currency: currency,
            priceHistory: priceHistory,
            currentPrice: currentPrice
        )
    }
}

public struct AssetTicker: Equatable, Hashable, Sendable {
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

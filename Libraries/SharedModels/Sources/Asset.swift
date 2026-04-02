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
}

public struct AssetTicker: Equatable, Hashable  {
    public let ticker: String
    public let exchange: Exchange
}

public struct AssetDayPrice: Equatable, Hashable  {
    public let date: Date
    public let price: Amount
}

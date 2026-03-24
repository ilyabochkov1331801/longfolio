//
//  Asset.swift
//  SharedModels
//
//  Created by Alena Nesterkina on 24.03.26.
//

import Foundation

public struct Asset {
    let ticker: AssetTicker
    let currency: Currency
    let priceHistory: [AssetDayPrice]
}

public struct AssetTicker {
    let ticker: String
}

public struct AssetDayPrice {
    let date: Date
    let price: Amount
    let asset: Asset
}

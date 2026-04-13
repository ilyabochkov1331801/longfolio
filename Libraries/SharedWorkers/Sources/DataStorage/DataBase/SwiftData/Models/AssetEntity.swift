//
//  AssetEntity.swift
//  SharedWorkers
//
//  Created by Илья Бочков on 20.03.26.
//

import Foundation
import SwiftData
import SharedModels

@Model
final class AssetEntity {
    var ticker: String
    var currency: Currency
    var exchange: ExchangeEntity
    
    @Relationship(deleteRule: .cascade, inverse: \AssetDayPriceEntity.asset)
    var priceHistory: [AssetDayPriceEntity]
    
    @Relationship(deleteRule: .cascade, inverse: \PositionEntity.asset)
    var positions: [PositionEntity]

    init(
        priceHistory: [AssetDayPriceEntity],
        ticker: String,
        currency: Currency,
        exchange: ExchangeEntity,
        positions: [PositionEntity]
    ) {
        self.priceHistory = priceHistory
        self.ticker = ticker
        self.currency = currency
        self.exchange = exchange
        self.positions = positions
    }
}

@Model
final class AssetDayPriceEntity {
    var date: Date
    var price: Amount
    var asset: AssetEntity
    
    init(date: Date, price: Amount, asset: AssetEntity) {
        self.date = date
        self.price = price
        self.asset = asset
    }
}

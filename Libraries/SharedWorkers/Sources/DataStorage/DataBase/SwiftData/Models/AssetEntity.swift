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
    @Relationship(deleteRule: .cascade, inverse: \AssetDayPriceEntity.asset)
    var priceHistory: [AssetDayPriceEntity]
    
    @Relationship
    var ticker: AssetTickerEntity
    
    var currency: Currency
    
    init(priceHistory: [AssetDayPriceEntity], currency: Currency, ticker: AssetTickerEntity) {
        self.priceHistory = priceHistory
        self.currency = currency
        self.ticker = ticker
    }
}

@Model
final class AssetTickerEntity {
    @Attribute(.unique)
    var ticker: String
    
    init(ticker: String) {
        self.ticker = ticker
    }
}

@Model
final class AssetDayPriceEntity {
    var date: Date
    var price: Amount
    var asset: AssetEntity?
    
    init(date: Date, price: Amount) {
        self.date = date
        self.price = price
    }
}

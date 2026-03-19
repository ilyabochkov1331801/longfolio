//
//  Models.swift
//  SharedWorkers
//
//  Created by Alena Nesterkina on 17.03.26.
//

import Foundation
import SwiftData
import SharedModels

struct AssetDayPrice {
    let date: Date
    let price: Amount
}

struct Amount {
    let value: Double
    let currency: Currency
}

@Model
final class AssetTicker {
    @Attribute(.unique) var id: String
    var ticker: String
    
    init(id: String = UUID().uuidString, ticker: String) {
        self.id = id
        self.ticker = ticker
    }
}

@Model
final class Asset {
    @Attribute(.unique) var id: String
    var ticker: AssetTicker
    var currency: Currency
    var priceHistory: [AssetDayPrice]
    
    init(id: String = UUID().uuidString, ticker: AssetTicker, currency: Currency, priceHistory: [AssetDayPrice]) {
        self.id = id
        self.ticker = ticker
        self.currency = currency
        self.priceHistory = priceHistory
    }
}

@Model
final class AssetTransaction {
    @Attribute(.unique) var id: String
    var date: Date
    var type: String // buy, sell
    var ticker: AssetTicker
    var quantity: Double
    var amount: Double
    
    init(id: String = UUID().uuidString, date: Date, type: String, ticker: AssetTicker, quantity: Double, amount: Double) {
        self.id = id
        self.date = date
        self.type = type
        self.ticker = ticker
        self.quantity = quantity
        self.amount = amount
    }
}

@Model
final class DividendTransaction {
    @Attribute(.unique) var id: String
    var date: Date
    var asset: AssetTicker
    var amount: Amount
    
    init(id: String = UUID().uuidString, date: Date, asset: AssetTicker, amount: Amount) {
        self.id = id
        self.date = date
        self.asset = asset
        self.amount = amount
    }
}

@Model
final class Position {
    @Attribute(.unique) var id: String
    var ticker: AssetTicker
    var quantity: Double
    var averageOpenPrice: Amount
    
    init(id: String = UUID().uuidString, ticker: AssetTicker, quantity: Double, averageOpenPrice: Amount) {
        self.id = id
        self.ticker = ticker
        self.quantity = quantity
        self.averageOpenPrice = averageOpenPrice
    }
}

@Model
final class PortfolioSnapshot {
    @Attribute(.unique) var id: String
    var date: Date
    var cashAmount: [Amount] // different currencies
    var positions: [PositionSnapshot]
    
    init(id: String = UUID().uuidString, date: Date, cashAmount: [Amount], positions: [PositionSnapshot]) {
        self.id = id
        self.date = date
        self.cashAmount = cashAmount
        self.positions = positions
    }
}

@Model
final class PositionSnapshot {
    @Attribute(.unique) var id: String
    var ticker: AssetTicker
    var quantity: Double
    var averageOpenPrice: Amount
    var currentPrice: Amount
    
    init(id: String = UUID().uuidString, ticker: AssetTicker, quantity: Double, averageOpenPrice: Amount, currentPrice: Amount) {
        self.id = id
        self.ticker = ticker
        self.quantity = quantity
        self.averageOpenPrice = averageOpenPrice
        self.currentPrice = currentPrice
    }
}

@Model
final class Portfolio {
    @Attribute(.unique) var id: String
    var cashAmount: [Amount] // different currencies
    var assetsTransactions: [AssetTransaction]
    var dividendsTransactions: [DividendTransaction]
    var positions: [Position]
    var snaphots: [PortfolioSnapshot]
    
    init(id: String = UUID().uuidString, cashAmount: [Amount], assetsTransactions: [AssetTransaction], dividendsTransactions: [DividendTransaction], positions: [Position], snaphots: [PortfolioSnapshot]) {
        self.id = id
        self.cashAmount = cashAmount
        self.assetsTransactions = assetsTransactions
        self.dividendsTransactions = dividendsTransactions
        self.positions = positions
        self.snaphots = snaphots
    }
}

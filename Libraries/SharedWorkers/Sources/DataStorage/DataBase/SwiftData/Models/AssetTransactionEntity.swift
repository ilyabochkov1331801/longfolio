//
//  TransactionEntity.swift
//  SharedWorkers
//
//  Created by Илья Бочков on 20.03.26.
//

import Foundation
import SwiftData
import SharedModels

@Model
final class BuyAssetTransactionEntity {
    @Attribute(.unique)
    var id: String
    
    @Relationship
    var asset: AssetEntity
        
    var date: Date
    var quantity: Double
    var amount: Amount
    var commision: Amount
    var portfolio: PortfolioEntity
    
    init(
        id: String,
        date: Date,
        asset: AssetEntity,
        quantity: Double,
        amount: Amount,
        commision: Amount,
        portfolio: PortfolioEntity
    ) {
        self.id = id
        self.date = date
        self.asset = asset
        self.quantity = quantity
        self.amount = amount
        self.commision = commision
        self.portfolio = portfolio
    }
}

@Model
final class SellAssetTransactionEntity {
    @Attribute(.unique)
    var id: String
    
    @Relationship
    var asset: AssetEntity
        
    var date: Date
    var quantity: Double
    var amount: Amount
    var commision: Amount
    var portfolio: PortfolioEntity
    var closedLots: [AssetLotEntity]
    var profit: Amount
    
    init(
        id: String,
        asset: AssetEntity,
        date: Date,
        quantity: Double,
        amount: Amount,
        commision: Amount,
        portfolio: PortfolioEntity,
        closedLots: [AssetLotEntity],
        profit: Amount
    ) {
        self.id = id
        self.asset = asset
        self.date = date
        self.quantity = quantity
        self.amount = amount
        self.commision = commision
        self.portfolio = portfolio
        self.closedLots = closedLots
        self.profit = profit
    }
}

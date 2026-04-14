//
//  DividendTransactionEntity.swift
//  SharedWorkers
//
//  Created by Илья Бочков on 20.03.26.
//

import Foundation
import SwiftData
import SharedModels

@Model
final class DividendTransactionEntity {
    @Attribute(.unique)
    var id: String
    
    @Relationship
    var asset: AssetEntity
    
    var date: Date
    var quantity: Double
    var amount: Amount
    var portfolio: PortfolioEntity
    
    init(
        id: String,
        date: Date,
        asset: AssetEntity,
        quantity: Double,
        amount: Amount,
        portfolio: PortfolioEntity
    ) {
        self.id = id
        self.date = date
        self.asset = asset
        self.quantity = quantity
        self.amount = amount
        self.portfolio = portfolio
    }
}

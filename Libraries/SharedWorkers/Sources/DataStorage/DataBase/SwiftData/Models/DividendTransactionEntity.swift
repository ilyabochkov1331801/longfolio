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
    var ticker: AssetTickerEntity
    
    var date: Date
    var quantity: Double
    var amount: Amount
    var portfolio: PortfolioEntity
    
    init(
        id: String,
        date: Date,
        ticker: AssetTickerEntity,
        quantity: Double,
        amount: Amount,
        portfolio: PortfolioEntity
    ) {
        self.id = id
        self.date = date
        self.ticker = ticker
        self.quantity = quantity
        self.amount = amount
        self.portfolio = portfolio
    }
}

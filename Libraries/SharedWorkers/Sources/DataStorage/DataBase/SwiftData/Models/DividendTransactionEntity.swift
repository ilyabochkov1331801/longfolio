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
    var amount: Amount
    var paidTaxes: Amount
    var portfolio: PortfolioEntity
    
    init(
        id: String,
        date: Date,
        asset: AssetEntity,
        amount: Amount,
        paidTaxes: Amount,
        portfolio: PortfolioEntity
    ) {
        self.id = id
        self.date = date
        self.asset = asset
        self.amount = amount
        self.paidTaxes = paidTaxes
        self.portfolio = portfolio
    }
}

//
//  CashTransactionEntity.swift
//  SharedWorkers
//
//  Created by Илья Бочков on 20.03.26.
//

import Foundation
import SwiftData
import SharedModels

@Model
final class CashTransactionEntity {
    @Attribute(.unique)
    var id: String
    
    var date: Date
    var amount: Amount
    var portfolio: PortfolioEntity?
    
    init(id: String, date: Date, amount: Amount) {
        self.id = id
        self.date = date
        self.amount = amount
    }
}

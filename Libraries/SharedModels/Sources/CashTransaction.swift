//
//  CashTransactionEntity.swift
//  SharedModels
//
//  Created by Alena Nesterkina on 24.03.26.
//

import Foundation

public struct CashTransaction: Equatable, Hashable  {
    public let id: String
    public let date: Date
    public let amount: Amount

    public init(id: String, date: Date, amount: Amount) {
        self.id = id
        self.date = date
        self.amount = amount
    }
}

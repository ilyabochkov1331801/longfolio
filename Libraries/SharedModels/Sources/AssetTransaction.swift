//
//  AssetTransaction.swift
//  SharedModels
//
//  Created by Alena Nesterkina on 24.03.26.
//

import Foundation

public struct AssetTransaction: Equatable, Hashable  {
    public let id: String
    public let date: Date
    public let type: AssetTransactionType
    public let quantity: Double
    public let amount: Amount

    public init(id: String, date: Date, type: AssetTransactionType, quantity: Double, amount: Amount) {
        self.id = id
        self.date = date
        self.type = type
        self.quantity = quantity
        self.amount = amount
    }
}

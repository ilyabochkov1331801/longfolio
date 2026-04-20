//
//  AssetTransaction.swift
//  SharedModels
//
//  Created by Alena Nesterkina on 24.03.26.
//

import Foundation

public struct AssetTransaction: Equatable, Hashable, Sendable {
    public let id: String
    public let date: Date
    public let type: AssetTransactionType
    public let quantity: Double
    public let amount: Amount
    public let asset: Asset

    public init(id: String, date: Date, type: AssetTransactionType, quantity: Double, amount: Amount, asset: Asset) {
        self.id = id
        self.date = date
        self.type = type
        self.quantity = quantity
        self.amount = amount
        self.asset = asset
    }
}

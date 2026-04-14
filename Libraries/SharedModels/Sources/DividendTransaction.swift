//
//  DividendTransaction.swift
//  SharedModels
//
//  Created by Alena Nesterkina on 24.03.26.
//

import Foundation

public struct DividendTransaction: Equatable, Hashable, Sendable {
    public let id: String
    public let date: Date
    public let asset: Asset
    public let amount: Amount

    public init(id: String, date: Date, asset: Asset, amount: Amount) {
        self.id = id
        self.date = date
        self.asset = asset
        self.amount = amount
    }
}

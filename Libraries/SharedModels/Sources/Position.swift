//
//  Position.swift
//  SharedModels
//
//  Created by Alena Nesterkina on 24.03.26.
//

import Foundation

public struct AssetLot: Equatable, Hashable, Sendable, Codable {
    public let id: UUID
    public let date: Date
    public let asset: Asset
    public let quantity: Double
    public let openAmount: Amount
    
    public init(id: UUID, date: Date, asset: Asset, quantity: Double, openAmount: Amount) {
        self.id = id
        self.date = date
        self.asset = asset
        self.quantity = quantity
        self.openAmount = openAmount
    }
}

public struct Position: Equatable, Hashable, Sendable {
    public let asset: Asset
    public let lots: [AssetLot]

    public init(asset: Asset, lots: [AssetLot]) {
        self.asset = asset
        self.lots = lots
    }
}

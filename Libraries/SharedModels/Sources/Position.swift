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

public extension AssetLot {
    var unitOpenAmount: Double {
        guard quantity != 0 else { return 0 }
        return openAmount.value / quantity
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

public extension Position {
    var quantity: Double {
        lots.reduce(0) { $0 + $1.quantity }
    }

    var openAmount: Amount {
        Amount(
            value: lots.reduce(0) { $0 + $1.openAmount.value },
            currency: asset.currency
        )
    }

    var lotCount: Int {
        lots.count
    }
}

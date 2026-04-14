//
//  Position.swift
//  SharedModels
//
//  Created by Alena Nesterkina on 24.03.26.
//

public struct Position: Equatable, Hashable, Sendable {
    public let asset: Asset
    public let quantity: Double
    public let openAmount: Amount

    public init(asset: Asset, quantity: Double, openAmount: Amount) {
        self.asset = asset
        self.quantity = quantity
        self.openAmount = openAmount
    }
}

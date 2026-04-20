//
//  SnapshotEntities.swift
//  SharedWorkers
//
//  Created by Илья Бочков on 20.03.26.
//

import Foundation
import SwiftData
import SharedModels

@Model
final class PositionSnapshotEntity {
    var asset: AssetTicker
    var quantity: Double
    var price: Amount
    var openAmount: Amount
    var portfolio: PortfolioSnapshotEntity
    
    init(
        asset: AssetTicker,
        quantity: Double,
        price: Amount,
        openAmount: Amount,
        portfolio: PortfolioSnapshotEntity
    ) {
        self.asset = asset
        self.quantity = quantity
        self.price = price
        self.openAmount = openAmount
        self.portfolio = portfolio
    }
}

@Model
final class PortfolioSnapshotEntity {
    @Relationship(deleteRule: .cascade, inverse: \PositionSnapshotEntity.portfolio)
    var positions: [PositionSnapshotEntity]
    
    var date: Date
    var name: String
    var cache: [Amount]
    var portfolio: PortfolioEntity
    
    init(
        positions: [PositionSnapshotEntity],
        date: Date,
        name: String,
        cache: [Amount],
        portfolio: PortfolioEntity
    ) {
        self.positions = positions
        self.date = date
        self.name = name
        self.cache = cache
        self.portfolio = portfolio
    }
}

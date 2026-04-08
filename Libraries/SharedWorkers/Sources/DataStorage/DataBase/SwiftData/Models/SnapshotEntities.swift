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
    @Relationship
    var ticker: AssetTickerEntity
    
    var quantity: Double
    var price: Amount
    var portfolio: PortfolioSnapshotEntity
    
    init(
        ticker: AssetTickerEntity,
        quantity: Double,
        price: Amount,
        portfolio: PortfolioSnapshotEntity
    ) {
        self.ticker = ticker
        self.quantity = quantity
        self.price = price
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

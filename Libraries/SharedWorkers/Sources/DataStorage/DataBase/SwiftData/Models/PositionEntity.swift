//
//  PositionEntity.swift
//  SharedWorkers
//
//  Created by Илья Бочков on 20.03.26.
//

import Foundation
import SwiftData
import SharedModels

@Model
final class AssetLotEntity {
    @Attribute(.unique)
    var id: UUID
    
    var asset: AssetEntity
    var quantity: Double
    var openAmount: Amount
    var date: Date
    
    init(id: UUID, asset: AssetEntity, quantity: Double, openAmount: Amount, date: Date) {
        self.id = id
        self.asset = asset
        self.quantity = quantity
        self.openAmount = openAmount
        self.date = date
    }
}

@Model
final class PositionEntity {
    var asset: AssetEntity
    var portfolio: PortfolioEntity

    @Relationship(deleteRule: .cascade)
    var lots: [AssetLotEntity]
    
    init(
        asset: AssetEntity,
        lots: [AssetLotEntity],
        portfolio: PortfolioEntity
    ) {
        self.asset = asset
        self.lots = lots
        self.portfolio = portfolio
    }
}

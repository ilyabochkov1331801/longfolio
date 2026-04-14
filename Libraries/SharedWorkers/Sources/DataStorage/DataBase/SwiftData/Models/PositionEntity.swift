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
final class PositionEntity {
    var asset: AssetEntity
    var quantity: Double
    var openAmount: Amount
    var portfolio: PortfolioEntity
    
    init(
        asset: AssetEntity,
        quantity: Double,
        openAmount: Amount,
        portfolio: PortfolioEntity
    ) {
        self.asset = asset
        self.quantity = quantity
        self.openAmount = openAmount
        self.portfolio = portfolio
    }
}

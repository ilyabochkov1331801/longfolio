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
    var averageOpenPrice: Amount
    var portfolio: PortfolioEntity
    
    init(
        asset: AssetEntity,
        quantity: Double,
        averageOpenPrice: Amount,
        portfolio: PortfolioEntity
    ) {
        self.asset = asset
        self.quantity = quantity
        self.averageOpenPrice = averageOpenPrice
        self.portfolio = portfolio
    }
}

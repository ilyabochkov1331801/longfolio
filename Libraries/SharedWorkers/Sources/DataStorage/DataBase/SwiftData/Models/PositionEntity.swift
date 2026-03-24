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
    @Relationship
    var ticker: AssetTickerEntity
    
    var quantity: Double
    var averageOpenPrice: Amount
    var portfolio: PortfolioEntity?
    
    init(ticker: AssetTickerEntity, quantity: Double, averageOpenPrice: Amount) {
        self.ticker = ticker
        self.quantity = quantity
        self.averageOpenPrice = averageOpenPrice
    }
}

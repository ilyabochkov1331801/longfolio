//
//  RealtimeAssetPriceEntity.swift
//  SharedWorkers
//
//  Created by Alena Nesterkina on 10.04.2026.
//

import Foundation
import SwiftData
import SharedModels

@Model
final class RealtimeAssetPriceEntity {
    @Relationship
    var ticker: AssetTickerEntity
    var close: Double
    
    init(ticker: AssetTickerEntity, close: Double) {
        self.ticker = ticker
        self.close = close
    }
}

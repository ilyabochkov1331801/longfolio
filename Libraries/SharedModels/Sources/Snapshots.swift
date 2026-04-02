//
//  Snapshots.swift
//  SharedModels
//
//  Created by Alena Nesterkina on 24.03.26.
//

import Foundation

public struct PositionSnapshot: Equatable, Hashable  {
    let ticker: AssetTicker
    let quantity: Double
    let price: Amount
}

public struct PortfolioSnapshot: Equatable, Hashable  {
    let positions: [PositionSnapshot]
    let date: Date
    let name: String
    let cache: [Amount]
}

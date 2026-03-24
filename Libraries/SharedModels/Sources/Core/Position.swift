//
//  Position.swift
//  SharedModels
//
//  Created by Alena Nesterkina on 24.03.26.
//

public struct Position {
    let ticker: AssetTicker
    let quantity: Double
    let averageOpenPrice: Amount
    let portfolio: Portfolio?
}

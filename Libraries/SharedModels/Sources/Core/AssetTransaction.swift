//
//  AssetTransaction.swift
//  SharedModels
//
//  Created by Alena Nesterkina on 24.03.26.
//

import Foundation

public struct AssetTransaction {
    let id: String
    let date: Date
    let type: AssetTransactionType
    let ticker: AssetTicker
    let quantity: Double
    let amount: Double
    let portfolio: Portfolio?
}

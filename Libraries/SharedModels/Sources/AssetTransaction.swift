//
//  AssetTransaction.swift
//  SharedModels
//
//  Created by Alena Nesterkina on 24.03.26.
//

import Foundation

public struct AssetTransaction: Equatable, Hashable  {
    let id: String
    let date: Date
    let type: AssetTransactionType
    let quantity: Double
    let amount: Amount
}

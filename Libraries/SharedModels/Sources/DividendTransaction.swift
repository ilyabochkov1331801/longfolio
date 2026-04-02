//
//  DividendTransaction.swift
//  SharedModels
//
//  Created by Alena Nesterkina on 24.03.26.
//

import Foundation

public struct DividendTransaction: Equatable, Hashable  {
    let id: String
    let date: Date
    let asset: AssetTicker
    let amount: Amount
}

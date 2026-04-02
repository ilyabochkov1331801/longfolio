//
//  Portfolio.swift
//  SharedModels
//
//  Created by Alena Nesterkina on 24.03.26.
//

import Foundation

public struct Portfolio: Equatable, Hashable {
    let name: String
    let cashAmount: [Amount] // different currencies
    let assetsTransactions: [AssetTransaction]
    let cashTransactions: [CashTransaction]
    let dividendsTransactions: [DividendTransaction]
    let positions: [Position]
    let snaphots: [PortfolioSnapshot]
}

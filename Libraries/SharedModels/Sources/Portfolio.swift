//
//  Portfolio.swift
//  SharedModels
//
//  Created by Alena Nesterkina on 24.03.26.
//

import Foundation

public struct Portfolio: Equatable, Hashable, Sendable {
    public let name: String
    public let cashAmount: [Amount]
    public let realizedProfit: [Amount]
    public let assetsTransactions: [AssetTransaction]
    public let cashTransactions: [CashTransaction]
    public let dividendsTransactions: [DividendTransaction]
    public let positions: [Position]
    public let snaphots: [PortfolioSnapshot]

    public init(
        name: String,
        cashAmount: [Amount],
        realizedProfit: [Amount] = [],
        assetsTransactions: [AssetTransaction],
        cashTransactions: [CashTransaction],
        dividendsTransactions: [DividendTransaction],
        positions: [Position],
        snaphots: [PortfolioSnapshot]
    ) {
        self.name = name
        self.cashAmount = cashAmount
        self.realizedProfit = realizedProfit
        self.assetsTransactions = assetsTransactions
        self.cashTransactions = cashTransactions
        self.dividendsTransactions = dividendsTransactions
        self.positions = positions
        self.snaphots = snaphots
    }
}

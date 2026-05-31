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

public extension Portfolio {
    static func combined(name: String, portfolios: [Portfolio]) -> Portfolio {
        Portfolio(
            name: name,
            cashAmount: sum(portfolios.flatMap(\.cashAmount)),
            realizedProfit: sum(portfolios.flatMap(\.realizedProfit)),
            assetsTransactions: portfolios.flatMap(\.assetsTransactions).sorted { $0.date > $1.date },
            cashTransactions: portfolios.flatMap(\.cashTransactions).sorted { $0.date > $1.date },
            dividendsTransactions: portfolios.flatMap(\.dividendsTransactions).sorted { $0.date > $1.date },
            positions: combinedPositions(from: portfolios),
            snaphots: combinedSnapshots(name: name, from: portfolios)
        )
    }

    private static func combinedPositions(from portfolios: [Portfolio]) -> [Position] {
        Dictionary(grouping: portfolios.flatMap(\.positions), by: \.asset)
            .map { asset, positions in
                Position(
                    asset: asset,
                    lots: positions.flatMap(\.lots).sorted { $0.date < $1.date }
                )
            }
            .sorted { $0.asset.ticker.ticker < $1.asset.ticker.ticker }
    }

    private static func combinedSnapshots(name: String, from portfolios: [Portfolio]) -> [PortfolioSnapshot] {
        let calendar = Calendar.current
        return Dictionary(grouping: portfolios.flatMap(\.snaphots)) { snapshot in
            calendar.startOfDay(for: snapshot.date)
        }
        .map { date, snapshots in
            PortfolioSnapshot.combined(name: name, date: date, snapshots: snapshots)
        }
        .sorted { $0.date > $1.date }
    }

    private static func sum(_ amounts: [Amount]) -> [Amount] {
        Array(
            amounts.reduce(into: [Currency: Amount]()) { result, amount in
                result[amount.currency] = Amount(
                    value: (result[amount.currency]?.value ?? 0) + amount.value,
                    currency: amount.currency
                )
            }.values
        )
    }
}

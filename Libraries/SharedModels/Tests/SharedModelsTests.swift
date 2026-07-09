import Foundation
import Testing
@testable import SharedModels

@Test func positionAggregatesQuantityAndOpenAmountFromLots() async throws {
    let position = Position(
        asset: makeAsset(),
        lots: [
            AssetLot(
                id: UUID(),
                date: .now,
                asset: makeAsset(),
                quantity: 2,
                openAmount: Amount(value: 200, currency: .usd)
            ),
            AssetLot(
                id: UUID(),
                date: .now,
                asset: makeAsset(),
                quantity: 3,
                openAmount: Amount(value: 360, currency: .usd)
            )
        ]
    )

    #expect(position.quantity == 5)
    #expect(position.openAmount == Amount(value: 560, currency: .usd))
    #expect(position.lotCount == 2)
}

@Test func sellTransactionExposesClosedLotsAndProfit() async throws {
    let lot = AssetLot(
        id: UUID(),
        date: .now,
        asset: makeAsset(),
        quantity: 1.5,
        openAmount: Amount(value: 120, currency: .usd)
    )
    let transactionType = AssetTransactionType.sell(
        profit: Amount(value: 25, currency: .usd),
        closedLots: [lot]
    )

    #expect(transactionType.isSell)
    #expect(transactionType.realizedProfit == Amount(value: 25, currency: .usd))
    #expect(transactionType.closedQuantity == 1.5)
    #expect(transactionType.closedOpenAmount == Amount(value: 120, currency: .usd))
}

@Test func combinedPortfolioMergesAmountsAndPositions() async throws {
    let asset = makeAsset()
    let firstLot = AssetLot(
        id: UUID(),
        date: Date(timeIntervalSince1970: 10),
        asset: asset,
        quantity: 1,
        openAmount: Amount(value: 100, currency: .usd)
    )
    let secondLot = AssetLot(
        id: UUID(),
        date: Date(timeIntervalSince1970: 20),
        asset: asset,
        quantity: 2,
        openAmount: Amount(value: 220, currency: .usd)
    )

    let portfolio = Portfolio.combined(
        name: "All portfolios",
        portfolios: [
            makePortfolio(
                name: "First",
                cashAmount: [Amount(value: 100, currency: .usd)],
                realizedProfit: [Amount(value: 10, currency: .usd)],
                lots: [firstLot]
            ),
            makePortfolio(
                name: "Second",
                cashAmount: [Amount(value: 50, currency: .usd)],
                realizedProfit: [Amount(value: -5, currency: .usd)],
                lots: [secondLot]
            )
        ]
    )

    #expect(portfolio.name == "All portfolios")
    #expect(portfolio.cashAmount == [Amount(value: 150, currency: .usd)])
    #expect(portfolio.realizedProfit == [Amount(value: 5, currency: .usd)])
    #expect(portfolio.positions.count == 1)
    #expect(portfolio.positions.first?.quantity == 3)
    #expect(portfolio.positions.first?.openAmount == Amount(value: 320, currency: .usd))
    #expect(portfolio.positions.first?.lots.map(\.id) == [firstLot.id, secondLot.id])
}

private func makeAsset() -> Asset {
    Asset(
        ticker: AssetTicker(
            ticker: "AAPL",
            exchange: Exchange(
                name: "NASDAQ",
                code: "US",
                country: "USA",
                currency: .usd
            )
        ),
        currency: .usd,
        priceHistory: []
    )
}

private func makePortfolio(
    name: String,
    cashAmount: [Amount],
    realizedProfit: [Amount],
    lots: [AssetLot]
) -> Portfolio {
    Portfolio(
        name: name,
        cashAmount: cashAmount,
        realizedProfit: realizedProfit,
        assetsTransactions: [],
        cashTransactions: [],
        dividendsTransactions: [],
        positions: [
            Position(asset: makeAsset(), lots: lots)
        ],
        snaphots: []
    )
}

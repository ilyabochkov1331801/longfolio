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

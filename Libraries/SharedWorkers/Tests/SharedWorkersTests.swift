import Foundation
import SharedModels
import Testing
@testable import SharedWorkers

@Test func openPositionsProfitSubtractsAggregatedLotCostBasis() async throws {
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
                quantity: 1,
                openAmount: Amount(value: 150, currency: .usd)
            )
        ]
    )
    let portfolio = Portfolio(
        name: "Test",
        cashAmount: [],
        assetsTransactions: [],
        cashTransactions: [],
        dividendsTransactions: [],
        positions: [position],
        snaphots: []
    )
    let manager = PortfolioStatisticsDataManager(
        realtimePricesProvider: RealtimePricesProviderStub(
            positionPrices: [position.asset.ticker.ticker: Amount(value: 420, currency: .usd)]
        )
    )

    let profit = try await manager.openPositionsProfit(in: portfolio)

    #expect(profit == [Amount(value: 70, currency: .usd)])
}

private struct RealtimePricesProviderStub: ProvidesRealtimePrices {
    let positionPrices: [String: Amount]

    func realtimePrice(for asset: Asset) async throws -> Amount {
        positionPrices[asset.ticker.ticker] ?? Amount(value: 0, currency: asset.currency)
    }

    func realtimePrice(for position: Position) async throws -> Amount {
        positionPrices[position.asset.ticker.ticker] ?? Amount(value: 0, currency: position.asset.currency)
    }

    func positionsRealtimePrice(in portfolio: Portfolio) async throws -> [Amount] {
        let amounts = portfolio.positions.compactMap { positionPrices[$0.asset.ticker.ticker] }
        return AmountCalculator.sum(of: amounts)
    }
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

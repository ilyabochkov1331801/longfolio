//
//  PortfolioDetailsScreenViewModel.swift
//  longfolio
//
//  Created by Assistant on 06.04.26.
//

import Foundation
import Combine
import SharedModels
import SharedWorkers
import Observation

@Observable
final class PortfolioDetailsScreenViewModel {
    private let portfolioDataManager: ManagesPortfolioData
    private let portfolioSnapshotDataManager: ManagesSnapshotData
    private let realtimePricesProvider: ProvidesRealtimePrices
    private let portfolioStatisticsManager: PortfolioStatisticsDataManager
    private let contextManager: ManagesSwiftDataContext
    private let converter: ConvertsCurrency
    private let settingsProvider: ProvidesSettings
    private let calendar = Calendar.current
    private let maximumSnapshotLookupDays = 30
    private let mode: PortfolioDetailsMode
    private var cancelBag: Set<AnyCancellable> = []
    private var sourcePortfolios: [Portfolio] = []
    
    var totalAmount: [Amount]?
    var profitAmount: [Amount]?
    var periodResults: [PortfolioDetailsPeriodResult] = []
    var portfolio: Portfolio
    
    var positionsForDisplaying: [Position] = []
    var positionsAmount: [Asset: Amount] = [:]
    var positionsProfit: [Asset: Amount] = [:]
    var positionsDisplayData: [Asset: PositionDisplayData] = [:]
    var canShowMorePositions = false
    var isReadOnly: Bool {
        mode == .allPortfolios
    }

    init(
        dependencyContainer: DIContainer,
        portfolio: Portfolio,
        mode: PortfolioDetailsMode = .single
    ) {
        self.contextManager = dependencyContainer.contextManager
        self.mode = mode
        let dataBase = SwiftDataBase(contextManager: dependencyContainer.contextManager)
        
        self.portfolioDataManager = PortfolioDataManager(dataBase: dataBase)
        self.portfolioSnapshotDataManager = SnapshotDataManager(
            dataBase: dataBase,
            networkService: dependencyContainer.eodhdNetworkService
        )
        
        self.realtimePricesProvider = RealtimePricesProvider(
            eodhdNetworkService: dependencyContainer.eodhdNetworkService,
            cache: dependencyContainer.realtimePriceCache
        )
        
        self.portfolioStatisticsManager = PortfolioStatisticsDataManager(
            realtimePricesProvider: realtimePricesProvider
        )
        self.converter = dependencyContainer.converter
        self.settingsProvider = dependencyContainer.settingsProvider
        
        self.portfolio = portfolio
        self.sourcePortfolios = mode == .allPortfolios ? [] : [portfolio]
        positionsForDisplaying = Array(portfolio.positions.prefix(5))
        canShowMorePositions = portfolio.positions.count > 2
        setupBindings()
    }
}

enum PortfolioDetailsMode: Hashable {
    case single
    case allPortfolios
}

struct PortfolioDetailsPeriodResult: Equatable, Hashable {
    let period: PortfolioDetailsResultPeriod
    let value: Double?
}

struct PositionDisplayData: Equatable {
    let baseCurrency: Currency
    let currentPrice: Amount
    let currentAmount: Amount
    let convertedCurrentAmount: Amount
    let profit: Amount
    let convertedProfit: Amount
    let profitPercent: Double?
    let lots: [PositionLotDisplayData]
}

struct PositionLotDisplayData: Equatable, Identifiable {
    let id: UUID
    let assetLot: AssetLot
    let quantity: Double
    let openPrice: Amount
    let currentAmount: Amount
    let convertedCurrentAmount: Amount
    let profit: Amount
    let convertedProfit: Amount
    let profitPercent: Double?
}

enum PortfolioDetailsResultPeriod: CaseIterable, Equatable, Hashable {
    case week
    case month
    case year

    var title: String {
        switch self {
        case .week:
            "Week"
        case .month:
            "Month"
        case .year:
            "Year"
        }
    }

    func startDate(from date: Date, calendar: Calendar) -> Date? {
        switch self {
        case .week:
            calendar.date(byAdding: .day, value: -7, to: date)
        case .month:
            calendar.date(byAdding: .month, value: -1, to: date)
        case .year:
            calendar.date(byAdding: .year, value: -1, to: date)
        }
    }
}

@MainActor
extension PortfolioDetailsScreenViewModel {
    func setupBindings() {
        contextManager.updatesPublisher
            .sink { [weak self] _ in
                Task { await self?.loadPortfolio() }
            }
            .store(in: &cancelBag)
    }

    func loadPortfolio() async {
        do {
            switch mode {
            case .single:
                guard let portfolio = try portfolioDataManager.fetchPortfolio(with: portfolio.name) else {
                    return
                }
                sourcePortfolios = [portfolio]
                self.portfolio = portfolio
            case .allPortfolios:
                let portfolios = try portfolioDataManager.fetchPortfolios()
                sourcePortfolios = portfolios
                portfolio = Portfolio.combined(name: "All portfolios", portfolios: portfolios)
            }
            positionsForDisplaying = Array(portfolio.positions.prefix(2))
            canShowMorePositions = portfolio.positions.count > 2
            await loadAmounts()
        } catch {
            
        }
    }

    func loadAmounts() async {
        do {
            totalAmount = try await portfolioStatisticsManager.totalAmount(in: portfolio)
            profitAmount = try await portfolioStatisticsManager.totalProfit(in: portfolio)
            positionsAmount.removeAll()
            positionsProfit.removeAll()
            positionsDisplayData.removeAll()
            let defaultCurrency = try settingsProvider.getDefaultCurrency()
            
            for position in portfolio.positions {
                let currentPrice = try await realtimePricesProvider.realtimePrice(for: position.asset)
                let currentAmount = Amount(
                    value: currentPrice.value * position.quantity,
                    currency: currentPrice.currency
                )
                let profit = Amount(
                    value: currentAmount.value - position.openAmount.value,
                    currency: currentAmount.currency
                )
                positionsAmount[position.asset] = currentAmount
                positionsProfit[position.asset] = profit
                positionsDisplayData[position.asset] = try await displayData(
                    for: position,
                    currentPrice: currentPrice,
                    currentAmount: currentAmount,
                    profit: profit,
                    defaultCurrency: defaultCurrency
                )
            }
            await loadPeriodResults()
        } catch {

        }
    }

    private func displayData(
        for position: Position,
        currentPrice: Amount,
        currentAmount: Amount,
        profit: Amount,
        defaultCurrency: Currency
    ) async throws -> PositionDisplayData {
        let convertedCurrentAmount = try await convert(currentAmount, to: defaultCurrency)
        let convertedProfit = try await convert(profit, to: defaultCurrency)
        var lots: [PositionLotDisplayData] = []
        for lot in position.lots.sorted(by: { $0.date < $1.date }) {
            let lotCurrentAmount = Amount(
                value: currentPrice.value * lot.quantity,
                currency: currentPrice.currency
            )
            let lotProfit = Amount(
                value: lotCurrentAmount.value - lot.openAmount.value,
                currency: lotCurrentAmount.currency
            )

            lots.append(PositionLotDisplayData(
                id: lot.id,
                assetLot: lot,
                quantity: lot.quantity,
                openPrice: Amount(value: lot.unitOpenAmount, currency: lot.openAmount.currency),
                currentAmount: lotCurrentAmount,
                convertedCurrentAmount: try await convert(lotCurrentAmount, to: defaultCurrency),
                profit: lotProfit,
                convertedProfit: try await convert(lotProfit, to: defaultCurrency),
                profitPercent: profitPercent(profit: lotProfit, openAmount: lot.openAmount)
            ))
        }

        return PositionDisplayData(
            baseCurrency: defaultCurrency,
            currentPrice: currentPrice,
            currentAmount: currentAmount,
            convertedCurrentAmount: convertedCurrentAmount,
            profit: profit,
            convertedProfit: convertedProfit,
            profitPercent: profitPercent(profit: profit, openAmount: position.openAmount),
            lots: lots
        )
    }

    private func convert(_ amount: Amount, to currency: Currency) async throws -> Amount {
        guard amount.currency != currency else {
            return amount
        }

        return try await converter.convert(to: currency, amount: amount, date: .now)
    }

    private func profitPercent(profit: Amount, openAmount: Amount) -> Double? {
        guard openAmount.value != 0 else {
            return nil
        }

        return profit.value / abs(openAmount.value)
    }

    func loadPeriodResults() async {
        guard let currentProfit = profitAmount else {
            periodResults = PortfolioDetailsResultPeriod.allCases.map {
                PortfolioDetailsPeriodResult(period: $0, value: nil)
            }
            return
        }

        var results: [PortfolioDetailsPeriodResult] = []
        for period in PortfolioDetailsResultPeriod.allCases {
            let value = await periodResult(for: period, currentProfit: currentProfit)
            results.append(PortfolioDetailsPeriodResult(period: period, value: value))
        }
        periodResults = results
    }

    private func periodResult(
        for period: PortfolioDetailsResultPeriod,
        currentProfit: [Amount]
    ) async -> Double? {
        guard
            let date = period.startDate(from: .now, calendar: calendar),
            let snapshot = await nearestAvailableSnapshot(startingFrom: date)
        else {
            return nil
        }

        do {
            let defaultCurrency = try settingsProvider.getDefaultCurrency()
            let currentProfit = try await converter.convert(
                to: defaultCurrency,
                amount: currentProfit,
                date: .now
            )
            let snapshotProfit = try await converter.convert(
                to: defaultCurrency,
                amount: snapshotProfit(for: snapshot),
                date: snapshot.date
            )
            let snapshotAmount = try await converter.convert(
                to: defaultCurrency,
                amount: snapshotAmount(for: snapshot),
                date: snapshot.date
            )
            let snapshotInvestedAmount = snapshotAmount.value - snapshotProfit.value
            guard snapshotInvestedAmount != 0 else {
                return nil
            }

            return (currentProfit.value - snapshotProfit.value) / abs(snapshotInvestedAmount)
        } catch {
            return nil
        }
    }

    private func nearestAvailableSnapshot(startingFrom date: Date) async -> PortfolioSnapshot? {
        for dayOffset in 0...maximumSnapshotLookupDays {
            guard let candidateDate = calendar.date(byAdding: .day, value: -dayOffset, to: date) else {
                continue
            }

            switch mode {
            case .single:
                do {
                    return try await portfolioSnapshotDataManager.getOrFetchSnapshot(
                        for: candidateDate,
                        portfolio: portfolio
                    )
                } catch {
                    continue
                }
            case .allPortfolios:
                var snapshots: [PortfolioSnapshot] = []
                for sourcePortfolio in sourcePortfolios {
                    do {
                        snapshots.append(
                            try await portfolioSnapshotDataManager.getOrFetchSnapshot(
                                for: candidateDate,
                                portfolio: sourcePortfolio
                            )
                        )
                    } catch {
                        continue
                    }
                }

                if !snapshots.isEmpty {
                    return PortfolioSnapshot.combined(
                        name: portfolio.name,
                        date: candidateDate,
                        snapshots: snapshots
                    )
                }
            }
        }

        return nil
    }

    private func snapshotAmount(for snapshot: PortfolioSnapshot) -> [Amount] {
        AmountCalculator.sum(of: snapshot.cache + snapshot.positions.map(\.price))
    }

    private func snapshotProfit(for snapshot: PortfolioSnapshot) -> [Amount] {
        let positionsProfit = AmountCalculator.difference(
            of: snapshot.positions.map(\.price),
            taken: snapshot.positions.map(\.openAmount)
        )
        return AmountCalculator.sum(of: positionsProfit + snapshot.realizedProfit)
    }
}

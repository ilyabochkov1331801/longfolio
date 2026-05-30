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
    private var cancelBag: Set<AnyCancellable> = []
    
    var totalAmount: [Amount]?
    var profitAmount: [Amount]?
    var periodResults: [PortfolioDetailsPeriodResult] = []
    var portfolio: Portfolio
    
    var positionsForDisplaying: [Position] = []
    var positionsAmount: [Asset: Amount] = [:]
    var positionsProfit: [Asset: Amount] = [:]
    var canShowMorePositions = false

    init(dependencyContainer: DIContainer, portfolio: Portfolio) {
        self.contextManager = dependencyContainer.contextManager
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
        positionsForDisplaying = Array(portfolio.positions.prefix(5))
        canShowMorePositions = portfolio.positions.count > 2
        setupBindings()
    }
}

struct PortfolioDetailsPeriodResult: Equatable, Hashable {
    let period: PortfolioDetailsResultPeriod
    let value: Double?
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
            guard let portfolio = try portfolioDataManager.fetchPortfolio(with: portfolio.name) else {
                return
            }

            self.portfolio = portfolio
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
            
            for position in portfolio.positions {
                let price = try await realtimePricesProvider.realtimePrice(for: position)
                positionsAmount[position.asset] = price
                positionsProfit[position.asset] = Amount(
                    value: price.value - position.openAmount.value,
                    currency: price.currency
                )
            }
            await loadPeriodResults()
        } catch {

        }
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

            do {
                return try await portfolioSnapshotDataManager.getOrFetchSnapshot(
                    for: candidateDate,
                    portfolio: portfolio
                )
            } catch {
                continue
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

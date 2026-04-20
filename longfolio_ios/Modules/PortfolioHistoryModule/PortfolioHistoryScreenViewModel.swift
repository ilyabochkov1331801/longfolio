//
//  PortfolioHistoryScreenViewModel.swift
//  longfolio
//
//  Created by Alena Nesterkina on 17.04.2026.
//

import Foundation
import Combine
import SharedModels
import SharedWorkers
import Observation

@Observable
final class PortfolioHistoryScreenViewModel {
    private let portfolioSnapshotDataManager: ManagesSnapshotData
    private let contextManager: ManagesSwiftDataContext
    private var cancelBag: Set<AnyCancellable> = []
    private let calendar = Calendar.current
    private let loadDataDelayNanoseconds: UInt64 = 300_000_000
    private var loadDataTask: Task<Void, Never>?
    
    private var portfolio: Portfolio
    var selectedSnapshot: PortfolioSnapshot?
    var errorMessage: String?
    
    var selectedDate = Date().addingTimeInterval(-24 * 60 * 60) {
        didSet {
            if isAfterMaximumSelectableDate(selectedDate) {
                selectedDate = maximumSelectableDate
            }
        }
    }
    var currentPositions: [PositionSnapshot] = []
    var maximumSelectableDate: Date { .now }
    var canSelectNextDay: Bool {
        guard let nextDate = calendar.date(byAdding: .day, value: 1, to: selectedDate) else {
            return false
        }
        
        return !isAfterMaximumSelectableDate(nextDate)
    }
    
    init(dependencyContainer: DIContainer, portfolio: Portfolio) {
        self.contextManager = dependencyContainer.contextManager
        let dataBase = SwiftDataBase(contextManager: dependencyContainer.contextManager)
        self.portfolio = portfolio
        self.portfolioSnapshotDataManager = SnapshotDataManager(
            dataBase: dataBase, networkService: dependencyContainer.eodhdNetworkService
        )
    }
    
    func selectPreviousDay() {
        updateSelectedDate(byAdding: -1)
    }
    
    func selectNextDay() {
        updateSelectedDate(byAdding: 1)
    }
    
    private func updateSelectedDate(byAdding days: Int) {
        guard let date = calendar.date(byAdding: .day, value: days, to: selectedDate) else {
            return
        }
        
        selectedDate = isAfterMaximumSelectableDate(date) ? maximumSelectableDate : date
        scheduleLoadData()
    }
    
    private func isAfterMaximumSelectableDate(_ date: Date) -> Bool {
        calendar.startOfDay(for: date) > calendar.startOfDay(for: maximumSelectableDate)
    }
    
    private func scheduleLoadData() {
        loadDataTask?.cancel()
        loadDataTask = Task { [weak self] in
            do {
                try await Task.sleep(nanoseconds: self?.loadDataDelayNanoseconds ?? 0)
            } catch {
                return
            }
            
            await self?.loadData()
        }
    }
    
    func loadData() async {
        errorMessage = nil
        
        if let data = portfolio.snaphots.first(where: { calendar.isDate($0.date, inSameDayAs: selectedDate) }) {
            self.selectedSnapshot = data
        }
        
        do {
            let snapshot = try await portfolioSnapshotDataManager.getOrFetchSnapshot(
                for: selectedDate, portfolio: portfolio
            )
            self.selectedSnapshot = snapshot
            self.currentPositions = snapshot.positions
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}

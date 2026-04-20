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
    
    private var portfolio: Portfolio
    
    var selectedDate = Date().addingTimeInterval(-24 * 60 * 60)
    var selectedSnapshot: PortfolioSnapshot?
    
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
        
        selectedDate = date
    }
    
    func loadData() async {
        if let data = portfolio.snaphots.first(where: { calendar.isDate($0.date, inSameDayAs: selectedDate) }) {
            self.selectedSnapshot = data
        }
        
        do {
            let snapshot = try await portfolioSnapshotDataManager.getOrFetchSnapshot(
                for: selectedDate, portfolio: portfolio
            )
            self.selectedSnapshot = snapshot
        } catch {
            print(error)
        }
    }
}

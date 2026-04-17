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
    
    var selectedDate = Date()
    var selectedSnapshot: PortfolioSnapshot?
    
    init(dependencyContainer: DIContainer, portfolio: Portfolio) {
        self.contextManager = dependencyContainer.contextManager
        let dataBase = SwiftDataBase(contextManager: dependencyContainer.contextManager)
        self.portfolio = portfolio
        self.portfolioSnapshotDataManager = SnapshotDataManager(dataBase: dataBase, networkService: dependencyContainer.eodhdNetworkService)
        
        loadData()
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
    
    private func loadData() {
        if let data = portfolio.snaphots.first(where: { calendar.isDate($0.date, inSameDayAs: selectedDate) }) {
            self.selectedSnapshot = data
        }
        
        do {
            let snapshot = try portfolioSnapshotDataManager.getOrFetchSnapshot(for: selectedDate, name: portfolio.name)
            self.selectedSnapshot = snapshot
        } catch {
            
        }
        
    }
}

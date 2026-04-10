//
//  CreateNewPortfolioScreenViewModel.swift
//  longfolio
//
//  Created by Assistant on 06.04.26.
//

import Foundation
import SharedWorkers

@Observable
final class CreateNewPortfolioScreenViewModel {
    private let portfolioDataManager: ManagesPortfolioData

    var portfolioName = ""
    var error: String?

    var canSave: Bool {
        portfolioName.count > 3
    }

    init(dependencyContainer: DIContainer) {
        let dataBase = SwiftDataBase(contextManager: dependencyContainer.contextManager)
        self.portfolioDataManager = PortfolioDataManager(dataBase: dataBase)
    }
}

@MainActor
extension CreateNewPortfolioScreenViewModel {
    func createPorftolio() {
        do {
            try portfolioDataManager.createNewPortfolio(with: portfolioName)
        } catch {
            self.error = error.localizedDescription
        }
    }
}

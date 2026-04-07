//
//  CreateNewPortfolioScreenViewModel.swift
//  longfolio
//
//  Created by Assistant on 06.04.26.
//

import Foundation
import SharedWorkers

struct CreateNewPortfolioScreenModel: Equatable {
    let portfolioName: String
    let canSave: Bool
}

@Observable
final class CreateNewPortfolioScreenViewModel {
    var state: BaseScreenViewState<CreateNewPortfolioScreenModel> = .normal(
        CreateNewPortfolioScreenModel(portfolioName: "", canSave: false)
    )

    private let portfolioDataManager: ManagesPortfolioData

    init(dependencyContainer: DIContainer) {
        let dataBase = SwiftDataBase(contextManager: dependencyContainer.contextManager)
        self.portfolioDataManager = PortfolioDataManager(dataBase: dataBase)
    }
}

@MainActor
extension CreateNewPortfolioScreenViewModel {
    func updatePortfolioName(_ name: String) {
        state = .normal(
            CreateNewPortfolioScreenModel(portfolioName: name, canSave: name.count > 3)
        )
    }

    func createPorftolio(with name: String)  {
        do {
            try portfolioDataManager.createNewPortfolio(with: name)
        } catch {
            state = .error(error)
        }
    }
}

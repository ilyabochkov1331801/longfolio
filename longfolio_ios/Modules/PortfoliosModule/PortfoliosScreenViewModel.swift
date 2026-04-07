//
//  PortfoliosScrenViewModel.swift
//  longfolio
//
//  Created by Илья Бочков on 2.04.26.
//

import Foundation
import SharedModels
import SharedWorkers

struct PortfoliosScreenModel {
    let portfolios: [Portfolio]
}

@Observable
final class PortfoliosScreenViewModel {
    var state: BaseScreenViewState<PortfoliosScreenModel> = .loading
    private let portfolioDataManager: ManagesPortfolioData

    init(dependencyContainer: DIContainer) {
        let dataBase = SwiftDataBase(contextManager: dependencyContainer.contextManager)
        self.portfolioDataManager = PortfolioDataManager(dataBase: dataBase)
    }
}

@MainActor
extension PortfoliosScreenViewModel {
    func loadPortfolios() async {
        do {
            let portfolios = try portfolioDataManager.fetchPortfolios()
            state = .normal(PortfoliosScreenModel(portfolios: portfolios))
        } catch {
            state = .error(error)
        }
    }
}

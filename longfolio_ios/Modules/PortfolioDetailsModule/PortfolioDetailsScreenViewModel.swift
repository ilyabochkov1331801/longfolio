//
//  PortfolioDetailsScreenViewModel.swift
//  longfolio
//
//  Created by Assistant on 06.04.26.
//

import Foundation
import SharedModels

struct PortfolioDetailsScreenModel: Equatable {
    let portfolio: Portfolio
}

@Observable
final class PortfolioDetailsScreenViewModel {
    var state: ScreenViewState<PortfolioDetailsScreenModel>

    init(dependencyContainer: DIContainer, portfolio: Portfolio) {
        self.state = .normal(PortfolioDetailsScreenModel(portfolio: portfolio))
    }
}

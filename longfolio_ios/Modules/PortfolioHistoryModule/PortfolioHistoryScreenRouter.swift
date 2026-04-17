//
//  HistoryScreenRouter.swift
//  longfolio
//
//  Created by Alena Nesterkina on 17.04.2026.
//

import Foundation
import SharedModels

enum PortfolioHistoryScreenRoute: Hashable, Identifiable {
    case portfolioHistory
}

final class PortfolioHistoryScreenRouter: DefaultRootRouter<PortfolioHistoryScreenRoute> { }

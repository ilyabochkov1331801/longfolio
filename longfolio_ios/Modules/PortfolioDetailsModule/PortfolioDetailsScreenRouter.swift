//
//  PortfolioDetailsScreenRouter.swift
//  longfolio
//
//  Created by Assistant on 06.04.26.
//

import Foundation
import SharedModels

enum PortfolioDetailsScreenRoute: Hashable, Identifiable {
    case transactions(Portfolio)
    case createCashTransaction(Portfolio)
    case createAssetTransaction(Portfolio)
    case createDividendTransaction(Portfolio)
}

final class PortfolioDetailsScreenRouter: DefaultRouter<PortfolioDetailsScreenRoute> { }

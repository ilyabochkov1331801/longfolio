//
//  PortfoliosScrenRouter.swift
//  longfolio
//
//  Created by Илья Бочков on 2.04.26.
//

import SharedModels
import SwiftUI

enum PortfoliosScreenRoute: Hashable, Identifiable {
    case createNewPortfolio
    case portfolioDetails(Portfolio)
}

final class PortfoliosScreenRouter: DefaultRootRouter<PortfoliosScreenRoute> { }

//
//  TabBarScreenRouter.swift
//  longfolio
//
//  Created by Илья Бочков on 2.04.26.
//

import Combine

enum Tab: Hashable {
    case portfolios
    case assets
    case settings
}

final class TabBarScreenRouter: ObservableObject {
    @Published var selectedTab: Tab = .portfolios
}

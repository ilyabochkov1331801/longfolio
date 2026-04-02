//
//  TabBarScreenViewModel.swift
//  longfolio
//
//  Created by Илья Бочков on 2.04.26.
//

import SwiftUI

@Observable
final class TabBarScreenViewModel {
    let portfoliosScrenViewModel: PortfoliosScrenViewModel
    
    init(dependencyContainer: DIContainer) {
        portfoliosScrenViewModel = PortfoliosScrenViewModel(dependencyContainer: dependencyContainer)
    }
}

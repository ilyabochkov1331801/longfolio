//
//  PortfoliosScrenViewModel.swift
//  longfolio
//
//  Created by Илья Бочков on 2.04.26.
//

import Combine
import SwiftData
import Foundation
import SharedModels
import SharedWorkers

struct PortfoliosScreenModel {
    let portfolios: [Portfolio]
}

@Observable
final class PortfoliosScreenViewModel {
    var state: BaseScreenViewState<PortfoliosScreenModel> = .loading
    
    private var cancelBag: Set<AnyCancellable> = []
    
    init(dependencyContainer: DIContainer) {
        
    }
}

@MainActor
extension PortfoliosScreenViewModel {
    func loadPortfolios() async {
        state = .normal(PortfoliosScreenModel(portfolios: []))
    }
}

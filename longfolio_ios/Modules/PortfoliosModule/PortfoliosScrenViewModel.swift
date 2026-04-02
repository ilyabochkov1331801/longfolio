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

struct PortfoliosScreenModel {
    let portfolios: [Portfolio]
}

@Observable
final class PortfoliosScrenViewModel {
    var state: BaseScreenViewState<PortfoliosScreenModel> = .loading
    
    private var cancelBag: Set<AnyCancellable> = []
    
    init(dependencyContainer: DIContainer) {
        
    }
}

@MainActor
extension PortfoliosScrenViewModel {
    func loadPortfolios() async {
        state = .normal(PortfoliosScreenModel(portfolios: []))
    }
}

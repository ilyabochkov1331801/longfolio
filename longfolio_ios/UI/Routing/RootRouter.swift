//
//  RootRouter.swift
//  longfolio
//
//  Created by Илья Бочков on 7.04.26.
//

import SwiftUI
import Combine

protocol RootRouter: Router {
    var navigationPath: NavigationPath { get set }
}

class DefaultRootRouter<Route: Hashable & Identifiable>: ObservableObject, RootRouter {
    @Published var navigationPath = NavigationPath()
    @Published var modalNavigationPath: Route?
    
    let parent: (any Router)?
    
    init(parent: (any Router)?) {
        self.parent = parent
    }
    
    func navigateBack() {
        navigationPath.removeLast()
    }
    
    func navigateToRoot() {
        navigationPath.removeLast(navigationPath.count)
    }
    
    func navigate(to route: Route) {
        navigationPath.append(route)
    }
    
    func navigateModaly(to route: Route) {
        modalNavigationPath = route
    }
    
    func dismiss() {
        modalNavigationPath = nil
        parent?.dismiss()
    }
}

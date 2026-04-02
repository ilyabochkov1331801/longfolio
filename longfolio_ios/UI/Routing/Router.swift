//
//  Router.swift
//  longfolio
//
//  Created by Илья Бочков on 2.04.26.
//

import SwiftUI
import Combine

protocol Router: ObservableObject {
    associatedtype Route: Hashable & Identifiable
    
    var navigationPath: NavigationPath { get set }
    var modalNavigationPath: Route? { get set }
    
    func navigateBack()
    func navigateToRoot()
    func navigate(to route: Route)
    func navigateModaly(to route: Route)
    func dismiss()
}

class DefaultRouter<Route: Hashable & Identifiable>: ObservableObject, Router {
    @Published var navigationPath = NavigationPath()
    @Published var modalNavigationPath: Route?
    
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
    }
}

extension Identifiable where Self: Hashable {
    var id: Int { hashValue }
}

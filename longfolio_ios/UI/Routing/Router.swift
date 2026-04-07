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
    
    var modalNavigationPath: Route? { get set }

    func navigateBack()
    func navigateToRoot()
    func navigate(to route: Route)
    func navigateModaly(to route: Route)
    func dismiss()
}

class DefaultRouter<Route: Hashable & Identifiable>: ObservableObject, Router {
    @Published var modalNavigationPath: Route?
    
    let root: any RootRouter
    let parent: (any Router)?
    
    init(root: any RootRouter, parent: (any Router)?) {
        self.root = root
        self.parent = parent
    }
    
    func navigateBack() {
        root.navigateBack()
    }
    
    func navigateToRoot() {
        root.navigateToRoot()
    }
    
    func navigate(to route: Route) {
        root.navigationPath.append(route)
    }
    
    func navigateModaly(to route: Route) {
        modalNavigationPath = route
    }
    
    func dismiss() {
        modalNavigationPath = nil
        parent?.dismiss()
    }
}

//
//  BaseScreenView.swift
//  longfolio
//
//  Created by Assistant on 06.04.26.
//

import SwiftUI

struct BaseScreenView<ContentView: View, ScreenRouter: Router, RouteView: View>: View {
    @ObservedObject private var router: ScreenRouter
    
    private let viewBuilder: () -> ContentView
    private let navigation: (ScreenRouter.Route) -> RouteView
    
    init(
        router: ScreenRouter,
        @ViewBuilder viewBuilder: @escaping () -> ContentView,
        @ViewBuilder navigation: @escaping (ScreenRouter.Route) -> RouteView
    ) {
        self.router = router
        self.viewBuilder = viewBuilder
        self.navigation = navigation
    }

    var body: some View {
        viewBuilder()
            .navigationDestination(for: ScreenRouter.Route.self, destination: navigation)
            .sheet(item: $router.modalNavigationPath, content: navigation)
    }
}

extension BaseScreenView where ScreenRouter.Route == EmptyRoute, RouteView == EmptyView {
    init(
        router: ScreenRouter,
        @ViewBuilder viewBuilder: @escaping () -> ContentView
    ) {
        self.init(
            router: router,
            viewBuilder: viewBuilder,
            navigation: { _ in }
        )
    }
}

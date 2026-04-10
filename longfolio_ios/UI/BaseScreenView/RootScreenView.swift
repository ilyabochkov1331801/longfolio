//
//  RootScreenView.swift
//  longfolio
//
//  Created by Илья Бочков on 2.04.26.
//

import SwiftUI

struct RootScreenView<ContentView: View, ScreenRouter: RootRouter, RouteView: View>: View {
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
        NavigationStack(path: $router.navigationPath) {
            viewBuilder()
                .navigationDestination(for: ScreenRouter.Route.self, destination: navigation)
                .sheet(item: $router.modalNavigationPath, content: navigation)
        }
    }
}

extension RootScreenView where ScreenRouter.Route == EmptyRoute, RouteView == EmptyView {
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

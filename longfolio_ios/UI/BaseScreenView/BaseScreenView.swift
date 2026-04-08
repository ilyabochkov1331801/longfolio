//
//  BaseScreenView.swift
//  longfolio
//
//  Created by Assistant on 06.04.26.
//

import SwiftUI

struct BaseScreenView<ContentView: View, ScreenModel: Equatable, ScreenRouter: Router, RouteView: View>: View {
    @ObservedObject private var router: ScreenRouter
    @Binding private var state: ScreenViewState<ScreenModel>
    
    private let viewBuilder: (ScreenModel) -> ContentView
    private let navigation: (ScreenRouter.Route) -> RouteView
    
    init(
        state: Binding<ScreenViewState<ScreenModel>>,
        router: ScreenRouter,
        @ViewBuilder viewBuilder: @escaping (ScreenModel) -> ContentView,
        @ViewBuilder navigation: @escaping (ScreenRouter.Route) -> RouteView
    ) {
        self._state = state
        self.router = router
        self.viewBuilder = viewBuilder
        self.navigation = navigation
    }

    var body: some View {
        ViewWrapper {
            switch state {
            case .loading:
                ProgressView()
            case .error(let error):
                Text(error.localizedDescription)
            case .normal(let model):
                viewBuilder(model)
            case .overlayLoading(let model):
                viewBuilder(model)
                    .disabled(true)
                    .overlay { ProgressView() }
            }
        }
        .animation(.default, value: state)
        .navigationDestination(for: ScreenRouter.Route.self, destination: navigation)
        .sheet(item: $router.modalNavigationPath, content: navigation)
    }
}

extension BaseScreenView where ScreenRouter.Route == EmptyRoute, RouteView == EmptyView {
    init(
        state: Binding<ScreenViewState<ScreenModel>>,
        router: ScreenRouter,
        @ViewBuilder viewBuilder: @escaping (ScreenModel) -> ContentView,
    ) {
        self.init(
            state: state,
            router: router,
            viewBuilder: viewBuilder,
            navigation: { _ in }
        )
    }
}

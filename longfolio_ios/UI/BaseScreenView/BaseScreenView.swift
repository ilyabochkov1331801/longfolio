//
//  BaseScreenView.swift
//  longfolio
//
//  Created by Илья Бочков on 2.04.26.
//

import SwiftUI

struct BaseScreenView<ContentView: View, ScreenModel, ScreenRouter: Router, RouteView: View>: View {
    @ObservedObject private var router: ScreenRouter
    @Binding private var state: BaseScreenViewState<ScreenModel>
    
    private let viewBuilder: (ScreenModel) -> ContentView
    private let navigation: (ScreenRouter.Route) -> RouteView
    
    init(
        state: Binding<BaseScreenViewState<ScreenModel>>,
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
        NavigationStack(path: $router.navigationPath) {
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
        }
        .navigationDestination(for: ScreenRouter.Route.self, destination: navigation)
        .sheet(item: $router.modalNavigationPath, content: navigation)
    }
}

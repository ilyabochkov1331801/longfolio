//
//  PortfoliosScreen.swift
//  longfolio
//
//  Created by Assistant on 06.04.26.
//

import SwiftUI
import SharedModels

struct PortfoliosScreen: View {
    @EnvironmentObject private var dependencyContainer: DIContainer

    @State var viewModel: PortfoliosScreenViewModel
    @StateObject var router: PortfoliosScreenRouter

    var body: some View {
        BaseScreenView(
            state: $viewModel.state,
            router: router
        ) { screenModel in
            Text("test")
        } navigation: { route in
            switch route {
            case .createNewPortfolio:
                EmptyView()
            case .portfolioDetails:
                EmptyView()
            }
        }
        .task { await viewModel.loadPortfolios() }
    }
}

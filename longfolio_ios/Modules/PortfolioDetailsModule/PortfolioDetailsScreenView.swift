//
//  PortfolioDetailsScreenView.swift
//  longfolio
//
//  Created by Assistant on 06.04.26.
//

import SwiftUI
import SharedModels

struct PortfolioDetailsScreenView: View {
    @State var viewModel: PortfolioDetailsScreenViewModel
    @StateObject var router: PortfolioDetailsScreenRouter

    var body: some View {
        BaseScreenView(state: $viewModel.state, router: router) { screenModel in
            content(screenModel)
                .navigationTitle(screenModel.portfolio.name)
        }
    }

    private func content(_ screenModel: PortfolioDetailsScreenModel) -> some View {
        List {
            Text(screenModel.portfolio.name)
                .font(.headline)
        }
        .listStyle(.plain)
    }
}

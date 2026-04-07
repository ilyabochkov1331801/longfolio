//
//  PortfoliosScreen.swift
//  longfolio
//
//  Created by Assistant on 06.04.26.
//

import SwiftUI
import SharedModels

struct PortfoliosScreen: View {
    @State var viewModel: PortfoliosScreenViewModel
    @StateObject var router: PortfoliosScreenRouter

    var body: some View {
        BaseScreenView(
            state: $viewModel.state,
            router: router
        ) { screenModel in
            content(screenModel)
        } navigation: { route in
            switch route {
            case .createNewPortfolio:
                EmptyView()
            case .portfolioDetails:
                EmptyView()
            }
        }
        .navigationTitle("Portfolios")
        .task {
            await viewModel.loadPortfolios()
        }
    }

    @ViewBuilder
    private func content(_ screenModel: PortfoliosScreenModel) -> some View {
        if screenModel.portfolios.isEmpty {
            ContentUnavailableView(
                "No portfolios yet",
                systemImage: "briefcase",
                description: Text("Create or import a portfolio to start tracking assets.")
            )
        } else {
            List(screenModel.portfolios, id: \.name) { portfolio in
                HStack(spacing: 12) {
                    Image(systemName: "briefcase.fill")
                        .foregroundStyle(.tint)

                    Text(portfolio.name)
                        .font(.headline)

                    Spacer()
                }
                .padding(.vertical, 4)
            }
            .listStyle(.plain)
        }
    }
}

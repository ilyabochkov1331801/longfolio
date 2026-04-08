//
//  PortfoliosScrenView.swift
//  longfolio
//
//  Created by Илья Бочков on 2.04.26.
//

import SwiftUI
import SharedModels

struct PortfoliosScreenView: View {
    @EnvironmentObject private var dependencyContainer: DIContainer

    @State var viewModel: PortfoliosScreenViewModel
    @StateObject var router: PortfoliosScreenRouter

    var body: some View {
        RootScreenView(
            state: $viewModel.state,
            router: router
        ) { screenModel in
            content(screenModel)
                .navigationTitle("Portfolios")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            router.navigateModaly(to: .createNewPortfolio)
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
        } navigation: { route in
            switch route {
            case .createNewPortfolio:
                CreateNewPortfolioScreenView(
                    viewModel: .init(dependencyContainer: dependencyContainer),
                    router: .init(parent: router)
                )
            case let .portfolioDetails(portfolio):
                PortfolioDetailsScreenView(
                    viewModel: .init(
                        dependencyContainer: dependencyContainer,
                        portfolio: portfolio
                    ),
                    router: .init(root: router, parent: router)
                )
            }
        }
        .task {
            viewModel.loadPortfolios()
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
            List {
                ForEach(screenModel.portfolios, id: \.name) { portfolio in
                    Button {
                        router.navigate(to: .portfolioDetails(portfolio))
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "briefcase.fill")
                                .foregroundStyle(.tint)

                            Text(portfolio.name)
                                .font(.headline)

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.footnote)
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .buttonStyle(.plain)
                    .padding(.vertical, 4)
                }
                .onDelete { indeces in
                    for index in indeces {
                        viewModel.deletePortfolio(with: screenModel.portfolios[index].name)
                    }
                }
            }
            .listStyle(.plain)
        }
    }
}

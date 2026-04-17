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
        RootScreenView(router: router) {
            screenContent
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
    private var screenContent: some View {
        List {
            ForEach(viewModel.portfolios, id: \.name) { portfolio in
                Button {
                    router.navigate(to: .portfolioDetails(portfolio))
                } label: {
                    PortfolioPreviewView(
                        portfolio: portfolio,
                        portfolioAmount: viewModel.amounts[portfolio.name],
                        profitAmount: viewModel.profits[portfolio.name]
                    ).onTapGesture {
                        router.navigate(to: .portfolioDetails(portfolio))
                    }
                }
                .buttonStyle(.borderless)
            }
            .onDelete { indeces in
                for index in indeces {
                    viewModel.deletePortfolio(with: viewModel.portfolios[index].name)
                }
            }
                        
            Section {
                HStack(alignment: .top) {
                    Text("Total")
                        .font(.headline)
                    
                    Spacer()
                    
                    if let totalAmount = viewModel.totalAmount {
                        VStack(alignment: .trailing) {
                            ForEach(totalAmount, id: \.currency) { amount in
                                AmountView(amount: amount)
                            }
                        }
                    } else {
                        ProgressView()
                            .padding()
                    }
                }
                .padding()
            }
            
        }
        .listStyle(.insetGrouped)
        .overlay {
            if viewModel.portfolios.isEmpty {
                ContentUnavailableView(
                    "No portfolios yet",
                    systemImage: "briefcase",
                    description: Text("Create or import a portfolio to start tracking assets.")
                )
            }
        }
    }
}


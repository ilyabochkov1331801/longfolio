//
//  PortfolioDetailsScreenView.swift
//  longfolio
//
//  Created by Assistant on 06.04.26.
//

import SwiftUI
import SharedModels

struct PortfolioDetailsScreenView: View {
    @EnvironmentObject private var dependencyContainer: DIContainer

    @State var viewModel: PortfolioDetailsScreenViewModel
    @StateObject var router: PortfolioDetailsScreenRouter

    var body: some View {
        BaseScreenView(router: router) {
            screenContent
        } navigation: { route in
            switch route {
            case let .transactions(portfolio):
                TransactionsScreenView(
                    viewModel: .init(dependencyContainer: dependencyContainer, portfolio: portfolio),
                    router: .init(root: router.root, parent: router)
                )
            case let .createCashTransaction(portfolio):
                CreateCashTransactionScreenView(
                    viewModel: .init(dependencyContainer: dependencyContainer, portfolio: portfolio),
                    router: .init(parent: router)
                )
            case let .createAssetTransaction(portfolio):
                SearchAssetsForTransactionScreenView(
                    viewModel: .init(dependencyContainer: dependencyContainer, portfolio: portfolio),
                    router: .init(parent: router)
                )
            case let .createDividendTransaction(portfolio):
                CreateDividendTransactionScreenView(
                    viewModel: .init(dependencyContainer: dependencyContainer, portfolio: portfolio),
                    router: .init(parent: router)
                )
            case let .openHistory(portfolio):
                PortfolioHistoryScreenView(
                    viewModel: .init(dependencyContainer: dependencyContainer, portfolio: portfolio),
                    router: .init(parent: router)
                )
            }
        }
        .task {
            await viewModel.loadPortfolio()
        }
    }

    @ViewBuilder
    private var screenContent: some View {
        List {
            PortfolioPreviewView(
                portfolio: viewModel.portfolio,
                portfolioAmount: viewModel.totalAmount,
                profitAmount: viewModel.profitAmount
            )

            Section("Cash Balance") {
                if viewModel.portfolio.cashAmount.isEmpty {
                    Text("No cash balance yet")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(viewModel.portfolio.cashAmount.sorted(), id: \.currency) { amount in
                        HStack {
                            Text(amount.currency.rawValue.uppercased())
                                .font(.headline)

                            Spacer()

                            AmountView(amount: amount)
                        }
                    }
                }
            }

            Section("Positions") {
                if viewModel.positionsForDisplaying.isEmpty {
                    Text("No positions yet")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(viewModel.positionsForDisplaying, id: \.asset) { position in
                        PositionPreviewView(
                            position: position,
                            amount: viewModel.positionsAmount[position.asset],
                            profit: viewModel.positionsProfit[position.asset]
                        )
                    }
                }
                
                if viewModel.canShowMorePositions {
                    Button("All positions") {
                        
                    }
                }
            }

            Section("Transactions") {
                Button {
                    router.navigate(to: .transactions(viewModel.portfolio))
                } label: {
                    HStack {
                        Text("Open Transactions")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.footnote)
                            .foregroundStyle(.tertiary)
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Portfolio Details")
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button {
                    router.navigate(to: .openHistory(viewModel.portfolio))
                } label: {
                    Image(systemName: "clock.arrow.circlepath")
                }

                Menu {
                    Button("Cash") {
                        router.navigateModaly(to: .createCashTransaction(viewModel.portfolio))
                    }

                    Button("Asset") {
                        router.navigateModaly(to: .createAssetTransaction(viewModel.portfolio))
                    }

                    Button("Dividends") {
                        router.navigateModaly(to: .createDividendTransaction(viewModel.portfolio))
                    }
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }
}

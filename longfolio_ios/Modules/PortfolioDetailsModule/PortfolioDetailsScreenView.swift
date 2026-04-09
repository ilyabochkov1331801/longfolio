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
        BaseScreenView(
            state: $viewModel.state,
            router: router
        ) { screenModel in
            content(screenModel)
                .navigationTitle(screenModel.portfolio.name)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Menu {
                            Button("Cash") {
                                router.navigateModaly(to: .createCashTransaction(screenModel.portfolio))
                            }

                            Button("Asset") {
                                router.navigateModaly(to: .createAssetTransaction(screenModel.portfolio))
                            }

                            Button("Dividends") {
                                router.navigateModaly(to: .createDividendTransaction(screenModel.portfolio))
                            }
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
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
            }
        }
        .task {
            viewModel.loadPortfolio()
        }
    }

    private func content(_ screenModel: PortfolioDetailsScreenModel) -> some View {
        List {
            Section("Portfolio") {
                Text(screenModel.portfolio.name)
                    .font(.headline)
            }

            Section("Cash Balance") {
                if screenModel.portfolio.cashAmount.isEmpty {
                    Text("No cash balance yet")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(screenModel.portfolio.cashAmount, id: \.currency) { amount in
                        HStack {
                            Text(amount.currency.rawValue.uppercased())
                                .font(.headline)

                            Spacer()

                            Text(amount.value, format: .number.precision(.fractionLength(2)))
                                .font(.body.weight(.medium))
                        }
                    }
                }
            }

            Section("Positions") {
                if screenModel.portfolio.positions.isEmpty {
                    Text("No positions yet")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(screenModel.portfolio.positions, id: \.ticker) { position in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(position.ticker.ticker)
                                    .font(.headline)

                                Spacer()

                                Text(position.quantity, format: .number.precision(.fractionLength(4)))
                                    .font(.body.weight(.medium))
                            }

                            HStack {
                                Text(position.ticker.exchange.code)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)

                                Spacer()

                                Text(
                                    position.averageOpenPrice.value,
                                    format: .number.precision(.fractionLength(2))
                                )
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 2)
                    }
                }
            }

            Section("Transactions") {
                Button {
                    router.navigate(to: .transactions(screenModel.portfolio))
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
        .listStyle(.plain)
    }
}

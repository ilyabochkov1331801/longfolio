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
            }
        }
        .task {
            await viewModel.loadPortfolio()
        }
    }

    @ViewBuilder
    private var screenContent: some View {
        List {
            Section("Portfolio") {
                HStack {
                    Text(viewModel.portfolio.name)
                        .font(.headline)

                    Spacer()

                    if let totalAmount = viewModel.totalAmount {
                        VStack(alignment: .trailing) {
                            ForEach(totalAmount.sorted(), id: \.currency) { amount in
                                AmountView(amount: amount)
                            }
                        }
                    } else {
                        ProgressView()
                            .padding()
                    }
                }
            }

            Section("Cash Balance") {
                if viewModel.portfolio.cashAmount.isEmpty {
                    Text("No cash balance yet")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(viewModel.portfolio.cashAmount, id: \.currency) { amount in
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
                if viewModel.portfolio.positions.isEmpty {
                    Text("No positions yet")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(viewModel.portfolio.positions, id: \.asset) { position in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(position.asset.ticker.ticker)
                                    .font(.headline)

                                Spacer()

                                Text(position.quantity, format: .number.precision(.fractionLength(4)))
                                    .font(.body.weight(.medium))
                            }

                            HStack {
                                Text(position.asset.ticker.exchange.code)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)

                                Spacer()

                                Text(
                                    position.openAmount.value,
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
        .listStyle(.plain)
        .navigationTitle(viewModel.portfolio.name)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
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


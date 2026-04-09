//
//  TransactionsScreenView.swift
//  longfolio
//
//  Created by Assistant on 08.04.26.
//

import SwiftUI
import SharedModels

struct TransactionsScreenView: View {
    @State var viewModel: TransactionsScreenViewModel
    @StateObject var router: TransactionsScreenRouter

    var body: some View {
        BaseScreenView(
            state: $viewModel.state,
            router: router
        ) { screenModel in
            content(screenModel)
                .navigationTitle("Transactions")
        }
        .task {
            viewModel.loadTransactions()
        }
    }

    private func content(_ screenModel: TransactionsScreenModel) -> some View {
        List {
            cashTransactionsSection(screenModel)
            assetTransactionsSection(screenModel)
            dividendTransactionsSection(screenModel)
        }
        .listStyle(.plain)
    }

    @ViewBuilder
    private func cashTransactionsSection(_ screenModel: TransactionsScreenModel) -> some View {
        Section("Cash Transactions") {
            if screenModel.portfolio.cashTransactions.isEmpty {
                Text("No cash transactions yet")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(screenModel.portfolio.cashTransactions, id: \.id) { transaction in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(transaction.amount.currency.rawValue.uppercased())
                                .font(.headline)
                            Text(transaction.date, style: .date)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Text(transaction.amount.value, format: .number.precision(.fractionLength(2)))
                            .font(.body.weight(.medium))
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func assetTransactionsSection(_ screenModel: TransactionsScreenModel) -> some View {
        Section("Asset Transactions") {
            if screenModel.portfolio.assetsTransactions.isEmpty {
                Text("No asset transactions yet")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(screenModel.portfolio.assetsTransactions, id: \.id) { transaction in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(String(describing: transaction.type).capitalized)
                                .font(.headline)
                            Text(transaction.date, style: .date)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Text(transaction.amount.value, format: .number.precision(.fractionLength(2)))
                            .font(.body.weight(.medium))
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func dividendTransactionsSection(_ screenModel: TransactionsScreenModel) -> some View {
        Section("Dividend Transactions") {
            if screenModel.portfolio.dividendsTransactions.isEmpty {
                Text("No dividend transactions yet")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(screenModel.portfolio.dividendsTransactions, id: \.id) { transaction in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(transaction.asset.ticker)
                                .font(.headline)
                            Text(transaction.date, style: .date)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Text(transaction.amount.value, format: .number.precision(.fractionLength(2)))
                            .font(.body.weight(.medium))
                    }
                }
            }
        }
    }
}

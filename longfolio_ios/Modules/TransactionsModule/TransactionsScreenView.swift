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
        BaseScreenView(router: router) {
            screenContent
        }
        .task {
            viewModel.loadTransactions()
        }
    }

    @ViewBuilder
    private var screenContent: some View {
        List {
            cashTransactionsSection
            assetTransactionsSection
            dividendTransactionsSection
        }
        .listStyle(.plain)
        .navigationTitle("Transactions")
    }

    @ViewBuilder
    private var cashTransactionsSection: some View {
        Section("Cash Transactions") {
            if viewModel.portfolio.cashTransactions.isEmpty {
                Text("No cash transactions yet")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(viewModel.portfolio.cashTransactions, id: \.id) { transaction in
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
    private var assetTransactionsSection: some View {
        Section("Asset Transactions") {
            if viewModel.portfolio.assetsTransactions.isEmpty {
                Text("No asset transactions yet")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(viewModel.portfolio.assetsTransactions, id: \.id) { transaction in
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
    private var dividendTransactionsSection: some View {
        Section("Dividend Transactions") {
            if viewModel.portfolio.dividendsTransactions.isEmpty {
                Text("No dividend transactions yet")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(viewModel.portfolio.dividendsTransactions, id: \.id) { transaction in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(transaction.asset.ticker.ticker)
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

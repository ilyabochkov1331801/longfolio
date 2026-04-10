//
//  CreateAssetTransactionDetailsScreenView.swift
//  longfolio
//
//  Created by Assistant on 08.04.26.
//

import SwiftUI
import SharedModels

struct CreateAssetTransactionDetailsScreenView: View {
    @State var viewModel: CreateAssetTransactionDetailsScreenViewModel
    @StateObject var router: CreateAssetTransactionDetailsScreenRouter

    var body: some View {
        BaseScreenView(router: router) {
            Form {
                Section("Asset") {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(viewModel.asset.ticker.ticker)
                            .font(.headline)
                        Text(viewModel.asset.ticker.exchange.code)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Transaction") {
                    Picker(
                        "Type",
                        selection: $viewModel.type
                    ) {
                        Text("Buy").tag(AssetTransactionType.buy)
                        Text("Sell").tag(AssetTransactionType.sell)
                    }

                    DatePicker(
                        "Date",
                        selection: $viewModel.date,
                        displayedComponents: .date
                    )

                    TextInput(
                        output: $viewModel.amount,
                        configuration: .init(
                            title: "Amount",
                            placeholder: "Enter amount",
                            hint: "Total transaction amount",
                            keyboardType: .decimalPad,
                            formatter: AmountTextInputFormatter()
                        )
                    )

                    TextInput(
                        output: $viewModel.quantity,
                        configuration: .init(
                            title: "Quantity",
                            placeholder: "Enter quantity",
                            hint: "Number of shares or units",
                            keyboardType: .decimalPad,
                            formatter: AmountTextInputFormatter()
                        )
                    )
                }
            }
            .navigationTitle("New Asset Transaction")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if viewModel.createTransaction() {
                            router.dismiss()
                        }
                    }
                    .disabled(!viewModel.canSave)
                }
            }
            .alert(
                "Something went wrong",
                isPresented: Binding(
                    get: { viewModel.error != nil },
                    set: { isPresented in if !isPresented { viewModel.error = nil } }
                ),
                actions: {
                    Button("OK", role: .cancel) { viewModel.error = nil }
                },
                message: {
                    Text(viewModel.error ?? "")
                }
            )
        }
    }
}

//
//  SellAssetTransactionScreenView.swift
//  longfolio
//
//  Created by Assistant on 30.05.26.
//

import SwiftUI
import SharedModels

struct SellAssetTransactionScreenView: View {
    @State var viewModel: SellAssetTransactionScreenViewModel
    @StateObject var router: SellAssetTransactionScreenRouter

    var body: some View {
        RootScreenView(router: router) {
            Form {
                Section("Asset") {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(viewModel.asset.ticker.ticker)
                                .font(.headline)
                            Text(viewModel.asset.ticker.exchange.code)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        if let currentPrice = viewModel.currentPrice {
                            AmountView(amount: currentPrice)
                        } else {
                            ProgressView()
                                .padding()
                        }
                    }
                }

                Section("Transaction") {
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
                            hint: "Total sale amount",
                            keyboardType: .decimalPad,
                            formatter: AmountTextInputFormatter()
                        )
                    )

                    TextInput(
                        output: $viewModel.quantity,
                        configuration: .init(
                            title: "Quantity",
                            placeholder: "Enter quantity",
                            hint: "Maximum \(viewModel.maximumQuantity.formatted())",
                            keyboardType: .decimalPad,
                            formatter: AmountTextInputFormatter()
                        )
                    )

                    TextInput(
                        output: $viewModel.commission,
                        configuration: .init(
                            title: "Commission",
                            placeholder: "Enter commission",
                            hint: "Broker fee in asset currency",
                            keyboardType: .decimalPad,
                            formatter: AmountTextInputFormatter()
                        )
                    )
                }
            }
            .navigationTitle("Sell Asset")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Sell") {
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
            .task {
                await viewModel.loadCurrentPrice()
            }
        }
    }
}

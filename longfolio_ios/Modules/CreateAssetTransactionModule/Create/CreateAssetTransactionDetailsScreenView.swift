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
        BaseScreenView(
            state: $viewModel.state,
            router: router
        ) { screenModel in
            Form {
                Section("Asset") {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(screenModel.asset.ticker.ticker)
                            .font(.headline)
                        Text(screenModel.asset.ticker.exchange.code)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Transaction") {
                    Picker(
                        "Type",
                        selection: Binding(
                            get: { screenModel.type },
                            set: { viewModel.updateType($0, model: screenModel) }
                        )
                    ) {
                        Text("Buy").tag(AssetTransactionType.buy)
                        Text("Sell").tag(AssetTransactionType.sell)
                    }

                    DatePicker(
                        "Date",
                        selection: Binding(
                            get: { screenModel.date },
                            set: { viewModel.updateDate($0, model: screenModel) }
                        ),
                        displayedComponents: .date
                    )

                    TextInput(
                        output: Binding(
                            get: { screenModel.amount },
                            set: { viewModel.updateAmount($0, model: screenModel) }
                        ),
                        configuration: .init(
                            title: "Amount",
                            placeholder: "Enter amount",
                            hint: "Total transaction amount",
                            keyboardType: .decimalPad,
                            formatter: AmountTextInputFormatter()
                        )
                    )

                    TextInput(
                        output: Binding(
                            get: { screenModel.quantity },
                            set: { viewModel.updateQuantity($0, model: screenModel) }
                        ),
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
                        if viewModel.createTransaction(model: screenModel) {
                            router.dismiss()
                        }
                    }
                    .disabled(!screenModel.canSave)
                }
            }
        }
    }
}

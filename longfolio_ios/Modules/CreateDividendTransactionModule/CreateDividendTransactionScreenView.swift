//
//  CreateDividendTransactionScreenView.swift
//  longfolio
//
//  Created by Assistant on 08.04.26.
//

import SwiftUI
import SharedModels

struct CreateDividendTransactionScreenView: View {
    @State var viewModel: CreateDividendTransactionScreenViewModel
    @StateObject var router: CreateDividendTransactionScreenRouter

    var body: some View {
        RootScreenView(router: router) {
            Form {
                Section("Transaction") {
                    if viewModel.positions.isEmpty {
                        Text("No positions available for dividends")
                            .foregroundStyle(.secondary)
                    } else {
                        Picker(
                            "Ticker",
                            selection: Binding(
                                get: { viewModel.selectedTicker ?? viewModel.positions.first!.ticker },
                                set: { viewModel.selectedTicker = $0 }
                            )
                        ) {
                            ForEach(viewModel.positions, id: \.ticker) { position in
                                Text(position.ticker.ticker).tag(position.ticker)
                            }
                        }
                    }

                    TextInput(
                        output: $viewModel.amountValue,
                        configuration: .init(
                            title: "Amount",
                            placeholder: "Enter amount",
                            hint: "Dividend amount received",
                            keyboardType: .decimalPad,
                            formatter: AmountTextInputFormatter()
                        )
                    )

                    DatePicker(
                        "Date",
                        selection: $viewModel.date,
                        displayedComponents: .date
                    )
                }
            }
            .navigationTitle("New Dividend")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        router.dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if viewModel.createDividendTransaction() {
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

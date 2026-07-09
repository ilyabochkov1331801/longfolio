//
//  CreateCashTransactionScreenView.swift
//  longfolio
//
//  Created by Assistant on 07.04.26.
//

import SwiftUI
import SharedModels

struct CreateCashTransactionScreenView: View {
    @State var viewModel: CreateCashTransactionScreenViewModel
    @StateObject var router: CreateCashTransactionScreenRouter

    var body: some View {
        RootScreenView(router: router) {
            Form {
                Section("Transaction") {
                    CurrencySelector(selection: $viewModel.selectedCurrency)

                    TextInput(
                        output: $viewModel.amountValue,
                        configuration: .init(
                            title: "Amount",
                            placeholder: "Enter amount",
                            hint: "Use a positive or negative value",
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
            .navigationTitle("New Cash Transaction")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        router.dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if viewModel.createCashTransaction() {
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

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
        RootScreenView(
            state: $viewModel.state,
            router: router
        ) { screenModel in
            Form {
                Section("Transaction") {
                    Picker(
                        "Currency",
                        selection: Binding(
                            get: { screenModel.selectedCurrency },
                            set: { viewModel.updateCurrency($0, with: screenModel) }
                        )
                    ) {
                        Text("USD").tag(Currency.usd)
                        Text("EUR").tag(Currency.eur)
                    }

                    TextInput(
                        output: Binding(
                            get: { screenModel.amountValue },
                            set: { viewModel.updateAmountValue($0, with: screenModel) }
                        ),
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
                        selection: Binding(
                            get: { screenModel.date },
                            set: { viewModel.updateDate($0, with: screenModel) }
                        ),
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
                        if viewModel.createCashTransaction(with: screenModel) {
                            router.dismiss()
                        }
                    }
                    .disabled(!screenModel.canSave)
                }
            }
        }
    }
}

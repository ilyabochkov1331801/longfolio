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
        RootScreenView(
            state: $viewModel.state,
            router: router
        ) { screenModel in
            Form {
                Section("Transaction") {
                    if screenModel.positions.isEmpty {
                        Text("No positions available for dividends")
                            .foregroundStyle(.secondary)
                    } else {
                        Picker(
                            "Ticker",
                            selection: Binding(
                                get: { screenModel.selectedTicker ?? screenModel.positions.first!.ticker },
                                set: { viewModel.updateTicker($0, with: screenModel) }
                            )
                        ) {
                            ForEach(screenModel.positions, id: \.ticker) { position in
                                Text(position.ticker.ticker).tag(position.ticker)
                            }
                        }
                    }

                    TextInput(
                        output: Binding(
                            get: { screenModel.amountValue },
                            set: { viewModel.updateAmountValue($0, with: screenModel) }
                        ),
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
                        selection: Binding(
                            get: { screenModel.date },
                            set: { viewModel.updateDate($0, with: screenModel) }
                        ),
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
                        if viewModel.createDividendTransaction(with: screenModel) {
                            router.dismiss()
                        }
                    }
                    .disabled(!screenModel.canSave)
                }
            }
        }
    }
}

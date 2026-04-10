//
//  CreateNewPortfolioScreenView.swift
//  longfolio
//
//  Created by Assistant on 06.04.26.
//

import SwiftUI

struct CreateNewPortfolioScreenView: View {
    @State var viewModel: CreateNewPortfolioScreenViewModel
    @StateObject var router: CreateNewPortfolioScreenRouter

    var body: some View {
        RootScreenView(router: router) {
            Form {
                Section("Portfolio") {
                    TextField(
                        "Name",
                        text: $viewModel.portfolioName
                    )
                    .textInputAutocapitalization(.words)
                }
            }
            .navigationTitle("New Portfolio")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        router.dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.createPorftolio()
                        router.dismiss()
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

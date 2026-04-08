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
        RootScreenView(
            state: $viewModel.state,
            router: router
        ) { screenModel in
            Form {
                Section("Portfolio") {
                    TextField(
                        "Name",
                        text: Binding(
                            get: { screenModel.portfolioName },
                            set: { viewModel.updatePortfolioName($0) }
                        )
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
                        viewModel.createPorftolio(with: screenModel.portfolioName)
                        router.dismiss()
                    }
                    .disabled(!screenModel.canSave)
                }
            }
        }
    }
}

//
//  SearchAssetsForTransactionScreenView.swift
//  longfolio
//
//  Created by Assistant on 08.04.26.
//

import SwiftUI
import SharedModels

struct SearchAssetsForTransactionScreenView: View {
    @EnvironmentObject private var dependencyContainer: DIContainer
    @State var viewModel: SearchAssetsForTransactionScreenViewModel
    @StateObject var router: SearchAssetsForTransactionScreenRouter

    var body: some View {
        RootScreenView(
            state: $viewModel.state,
            router: router
        ) { screenModel in
            content(screenModel)
                .navigationTitle("Select Asset")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") {
                            router.dismiss()
                        }
                    }
                }
        } navigation: { route in
            switch route {
            case let .createWithAsset(asset):
                CreateAssetTransactionDetailsScreenView(
                    viewModel: .init(
                        dependencyContainer: dependencyContainer,
                        portfolioName: viewModel.portfolioName,
                        asset: asset
                    ),
                    router: .init(root: router, parent: router)
                )
            }
        }
    }

    @ViewBuilder
    private func content(_ screenModel: SearchAssetsForTransactionScreenModel) -> some View {
        List {
            if screenModel.displayedAssets.isEmpty {
                ContentUnavailableView(
                    "No assets found",
                    systemImage: "magnifyingglass",
                    description: Text(emptyStateDescription(for: screenModel))
                )
                .listRowSeparator(.hidden)
            } else {
                ForEach(screenModel.displayedAssets, id: \.self) { asset in
                    Button {
                        router.navigate(to: .createWithAsset(asset))
                    } label: {
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(asset.ticker.ticker)
                                    .font(.headline)
                                Text(asset.ticker.exchange.code)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.footnote)
                                .foregroundStyle(.tertiary)
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .listStyle(.plain)
        .searchable(
            text: $viewModel.tickerQuery,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: "Search asset or exchange"
        )
    }

    private func emptyStateDescription(for screenModel: SearchAssetsForTransactionScreenModel) -> String {
        if screenModel.searchQuery.isEmpty {
            return "Assets from the portfolio will appear here."
        }

        return "Try another ticker or exchange."
    }
}

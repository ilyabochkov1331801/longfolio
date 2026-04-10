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
        RootScreenView(router: router) {
            screenContent
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
    private var screenContent: some View {
        List {
            if viewModel.displayedAssets.isEmpty {
                ContentUnavailableView(
                    "No assets found",
                    systemImage: "magnifyingglass",
                    description: Text(viewModel.emptyStateDescription())
                )
                .listRowSeparator(.hidden)
            } else {
                ForEach(viewModel.displayedAssets, id: \.self) { asset in
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
        .navigationTitle("Select Asset")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Close") {
                    router.dismiss()
                }
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

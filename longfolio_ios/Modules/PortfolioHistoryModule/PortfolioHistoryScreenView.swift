//
//  PortfolioHistoryScreenView.swift
//  longfolio
//
//  Created by Alena Nesterkina on 17.04.2026.
//

import SwiftUI
import SharedModels

struct PortfolioHistoryScreenView: View {
    @EnvironmentObject private var dependencyContainer: DIContainer
    
    @State var viewModel: PortfolioHistoryScreenViewModel
    @StateObject var router: PortfolioHistoryScreenRouter
    
    var body: some View {
        RootScreenView(router: router) {
            snapshotContent
                .background(Color(.systemGroupedBackground))
                .navigationTitle("History")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        datePickerToolbar
                    }
                }
                .task {
                    await viewModel.loadData()
                }
        }
    }

    private var datePickerToolbar: some View {
        HStack(spacing: 4) {
            Button {
                viewModel.selectPreviousDay()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.body.weight(.semibold))
                    .frame(width: 34, height: 34)
                    .contentShape(Circle())
            }
            .buttonStyle(.glass)

            datePickerButton

            Button {
                viewModel.selectNextDay()
            } label: {
                Image(systemName: "chevron.right")
                    .font(.body.weight(.semibold))
                    .frame(width: 34, height: 34)
                    .contentShape(Circle())
            }
            .buttonStyle(.glass)
            .disabled(!viewModel.canSelectNextDay)
            .opacity(viewModel.canSelectNextDay ? 1 : 0.35)
        }
    }

    private var datePickerButton: some View {
        DatePicker(
            "",
            selection: $viewModel.selectedDate,
            in: ...viewModel.maximumSelectableDate,
            displayedComponents: .date
        )
        .datePickerStyle(.compact)
        .labelsHidden()
        .frame(minWidth: 150, minHeight: 34)
        .padding(.horizontal, 10)
    }
    
    @ViewBuilder
    private var snapshotContent: some View {
        List {
            Section {
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 24)
                } else if let errorMessage = viewModel.errorMessage {
                    ContentUnavailableView(
                        "Something went wrong",
                        systemImage: "briefcase",
                        description: Text(errorMessage)
                    )
                } else {
                    VStack(alignment: .leading, spacing: 22) {
                        cashTransactionsSection
                        positionsSection
                    }
                    .padding(.vertical, 4)
                }
            }
            .listRowSeparator(.hidden)
        }
        .listStyle(.insetGrouped)
    }
    
    @ViewBuilder
    private var positionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Positions")
            
            if viewModel.currentPositions.isEmpty {
                Text("No positions yet")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(viewModel.currentPositions, id: \.ticker) { position in
                    PositionPreviewView(position: position)
                }
            }
        }
    }
    
    @ViewBuilder
    private var cashTransactionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Cash Transactions")
            
            if let snapshot = viewModel.selectedSnapshot, !snapshot.cache.isEmpty {
                ForEach(snapshot.cache, id: \.hashValue) { cache in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(cache.currency.rawValue.uppercased())
                                .font(.headline)
                        }
                        
                        Spacer()
                        
                        Text(cache.value, format: .number.precision(.fractionLength(2)))
                            .font(.body.weight(.medium))
                    }
                }
            } else {
                Text("No cash transactions yet")
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.caption.weight(.semibold))
            .foregroundStyle(.secondary)
            .textCase(.uppercase)
    }
}

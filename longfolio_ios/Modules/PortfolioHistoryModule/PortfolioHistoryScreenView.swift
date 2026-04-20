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
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                Spacer()
                
                HStack(spacing: 12) {
                    Button {
                        viewModel.selectPreviousDay()
                    } label: {
                        Image(systemName: "chevron.left")
                    }
                    .buttonStyle(.bordered)
                    
                    DatePicker(
                        "",
                        selection: $viewModel.selectedDate,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    
                    Button {
                        viewModel.selectNextDay()
                    } label: {
                        Image(systemName: "chevron.right")
                    }
                    .buttonStyle(.bordered)
                }
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            
            List {
                Section("Portfolio") {
                    Text(viewModel.selectedSnapshot?.name ?? "No data provided")
                        .foregroundStyle(.secondary)
                }
            }
            .listStyle(.insetGrouped)
        }
        .background(Color(.systemGroupedBackground))
        .task {
            await viewModel.loadData()
        }
    }
}

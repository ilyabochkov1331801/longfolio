//
//  SettingsScreenView.swift
//  longfolio
//
//  Created by Alena Nesterkina on 21.04.2026.
//

import SwiftUI
import SharedModels

struct SettingsScreenView: View {
    @State var viewModel: SettingsScreenViewModel
    
    var body: some View {
        List {
            Section("Personal") {
                Text("No data yet")
                    .foregroundStyle(.secondary)
            }
            
            Section("Main") {
                VStack {
                    CurrencySelector(selection: $viewModel.defaultCurrency)
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}

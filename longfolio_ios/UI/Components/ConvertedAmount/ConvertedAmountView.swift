//
//  ConvertedAmountView.swift
//  longfolio
//
//  Created by Alena Nesterkina on 23.04.2026.
//

import SwiftUI
import SharedModels

public struct ConvertedAmountView: View {
    var viewModel: ConvertedAmountViewModel
    
    public var body: some View {
        HStack {
            amountView
            InfoView() {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(viewModel.amount, id: \.currency) { amount in
                        AmountView(amount: amount)
                    }
                    ForEach(viewModel.profitAmount, id: \.currency) { amount in
                        ProfitAmountView(profit: amount)
                    }
                }
            }
        }
        .task {
            await viewModel.setupData()
        }
    }
    
    @ViewBuilder
    private var amountView: some View {
        HStack {
            if let amount = viewModel.convertedAmount {
                AmountView(amount: amount)
            } else {
                ProgressView()
            }
            
            if let profitAmount = viewModel.convertedProfit, profitAmount.value != 0.0 {
                ProfitAmountView(profit: profitAmount)
            }
        }
    }
}


//
//  ConvertedAmountView.swift
//  longfolio
//
//  Created by Alena Nesterkina on 23.04.2026.
//

import SwiftUI
import SharedModels

public struct ConvertedAmountView: View {
    @State private var viewModel: ConvertedAmountViewModel
    private let amount: [Amount]
    private let profitAmount: [Amount]
    private let convertedDate: Date

    init(viewModel: ConvertedAmountViewModel) {
        self.amount = viewModel.amount
        self.profitAmount = viewModel.profitAmount
        self.convertedDate = Date()
        _viewModel = State(initialValue: viewModel)
    }
    
    public var body: some View {
        HStack {
            amountView
            InfoView() {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(currencyRows, id: \.amount.currency) { row in
                        HStack(alignment: .firstTextBaseline, spacing: 8) {
                            AmountView(amount: row.amount)

                            if let profit = row.profit, profit.value != 0 {
                                ProfitAmountView(profit: profit)
                            }
                        }
                    }
                }
            }
        }
        .task {
            viewModel.update(amount: amount, profitAmount: profitAmount, convertedDate: convertedDate)
            await viewModel.setupData()
        }
        .onChange(of: amount) {
            viewModel.update(amount: amount, profitAmount: profitAmount, convertedDate: convertedDate)
            Task {
                await viewModel.setupData()
            }
        }
        .onChange(of: profitAmount) {
            viewModel.update(amount: amount, profitAmount: profitAmount, convertedDate: convertedDate)
            Task {
                await viewModel.setupData()
            }
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

    private var currencyRows: [(amount: Amount, profit: Amount?)] {
        viewModel.amount.map { amount in
            let profit = viewModel.profitAmount.first(where: { $0.currency == amount.currency })
            return (amount: amount, profit: profit)
        }
    }
}

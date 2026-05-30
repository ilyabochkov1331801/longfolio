//
//  ConvertedAmountView.swift
//  longfolio
//
//  Created by Alena Nesterkina on 23.04.2026.
//

import SwiftUI
import SharedModels

public struct ConvertedAmountView: View {
    enum DisplayMode {
        case amountAndProfit
        case amountOnly
        case profitOnly
    }

    @State private var viewModel: ConvertedAmountViewModel
    private let amount: [Amount]
    private let profitAmount: [Amount]
    private let convertedDate: Date
    private let displayMode: DisplayMode
    private let showsDetails: Bool

    init(
        viewModel: ConvertedAmountViewModel,
        displayMode: DisplayMode = .amountAndProfit,
        showsDetails: Bool = true
    ) {
        self.amount = viewModel.amount
        self.profitAmount = viewModel.profitAmount
        self.convertedDate = Date()
        self.displayMode = displayMode
        self.showsDetails = showsDetails
        _viewModel = State(initialValue: viewModel)
    }
    
    public var body: some View {
        HStack {
            amountView
            
            if showsDetails {
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
                    .font(.body)
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
            switch displayMode {
            case .amountAndProfit:
                if let amount = viewModel.convertedAmount {
                    AmountView(amount: amount)
                } else {
                    ProgressView()
                }

                if let profitAmount = viewModel.convertedProfit, profitAmount.value != 0.0 {
                    ProfitAmountView(profit: profitAmount)
                }
            case .amountOnly:
                if let amount = viewModel.convertedAmount {
                    AmountView(amount: amount)
                } else {
                    ProgressView()
                }
            case .profitOnly:
                if let profitAmount = viewModel.convertedProfit {
                    ProfitAmountView(profit: profitAmount)
                } else {
                    ProgressView()
                }
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

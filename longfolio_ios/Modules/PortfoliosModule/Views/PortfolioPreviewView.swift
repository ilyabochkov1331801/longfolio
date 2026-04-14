//
//  PortfolioPreviewView.swift
//  longfolio
//
//  Created by Илья Бочков on 13.04.26.
//

import SwiftUI
import SharedModels

struct PortfolioPreviewView: View {
    let portfolio: Portfolio
    let portfolioAmount: [Amount]?
    let profitAmount: [Amount]?
    
    var body: some View {
        HStack(alignment: .top) {
            Text(portfolio.name)
                .font(.headline)
            
            Spacer()
            
            if let portfolioAmount, let profitAmount {
                VStack(alignment: .trailing) {
                    ForEach(portfolioAmount.sorted(), id: \.currency) { amount in
                        AmountView(amount: amount)
                    }
                }
                
                VStack(alignment: .trailing) {
                    ForEach(profitAmount.sorted(), id: \.currency) { amount in
                        ProfitAmountView(profit: amount)
                    }
                }
            } else {
                ProgressView()
                    .padding()
            }
        }
        .padding()
    }
}

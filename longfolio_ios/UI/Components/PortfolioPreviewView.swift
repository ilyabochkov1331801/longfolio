//
//  PortfolioPreviewView.swift
//  longfolio
//
//  Created by Илья Бочков on 14.04.26.
//

import SwiftUI
import SharedModels

struct PortfolioPreviewView: View {
    @EnvironmentObject private var dependencyContainer: DIContainer
    
    let portfolio: Portfolio
    let portfolioAmount: [Amount]?
    let profitAmount: [Amount]?
    
    var body: some View {
        HStack(alignment: .top) {
            Text(portfolio.name)
                .font(.headline)
                .foregroundStyle(.black)
            
            Spacer()
            
            if let portfolioAmount, let profitAmount {
                ConvertedAmountView(viewModel: .init(
                    diContatiner: dependencyContainer,
                    amount: portfolioAmount,
                    profitAmount: profitAmount,
                    convertedDate: Date()
                ))
            } else {
                ProgressView()
                    .padding()
            }
        }
        .padding()
    }
}

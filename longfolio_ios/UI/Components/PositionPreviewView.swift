//
//  PositionPreviewView.swift
//  longfolio
//
//  Created by Илья Бочков on 14.04.26.
//

import SwiftUI
import SharedModels

struct PositionPreviewView: View {
    let position: Position
    let amount: Amount?
    let profit: Amount?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(position.asset.ticker.ticker)
                    .font(.headline)

                Spacer()

                Text(position.quantity, format: .number.precision(.fractionLength(2)))
                    .font(.body.weight(.medium))
            }

            HStack {
                Text(position.asset.ticker.exchange.code)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                if let amount, let profit {
                    AmountView(amount: amount)
                    ProfitAmountView(profit: profit)
                } else {
                    ProgressView()
                        .padding()
                }
            }
        }
        .padding(.vertical, 2)
    }
}

//
//  PositionPreviewView.swift
//  longfolio
//
//  Created by Илья Бочков on 14.04.26.
//

import SwiftUI
import SharedModels

struct PositionPreviewView: View {
    private let ticker: String
    private let exchange: String
    private let quantity: Double
    private let amount: Amount?
    private let profit: Amount?
    
    init(position: Position, amount: Amount?, profit: Amount?) {
        self.ticker = position.asset.ticker.ticker
        self.exchange = position.asset.ticker.exchange.code
        self.quantity = position.lots.reduce(0, { $0 + $1.quantity })
        self.amount = amount
        self.profit = profit
    }
    
    init(position: PositionSnapshot) {
        self.ticker = position.ticker.ticker
        self.exchange = position.ticker.exchange.code
        self.quantity = position.quantity
        self.amount = position.price
        self.profit = Amount(
            value: position.price.value - position.openAmount.value,
            currency: position.price.currency
        )
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(ticker)
                    .font(.headline)

                Spacer()

                Text(quantity, format: .number)
                    .font(.body.weight(.medium))
            }

            HStack {
                Text(exchange)
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

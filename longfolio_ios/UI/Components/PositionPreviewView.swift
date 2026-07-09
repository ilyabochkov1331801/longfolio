//
//  PositionPreviewView.swift
//  longfolio
//
//  Created by Илья Бочков on 14.04.26.
//

import SwiftUI
import SharedModels

struct PositionPreviewView: View {
    private let title: String
    private let quantity: Double
    private let openPrice: Amount?
    private let amount: Amount?
    private let profit: Amount?
    private let displayData: PositionDisplayData?
    private let lotData: PositionLotDisplayData?
    
    init(position: Position, amount: Amount?, profit: Amount?, displayData: PositionDisplayData? = nil) {
        self.title = "\(position.asset.ticker.ticker).\(position.asset.ticker.exchange.code)"
        self.quantity = position.quantity
        self.openPrice = Self.unitOpenPrice(quantity: position.quantity, openAmount: position.openAmount)
        self.amount = amount
        self.profit = profit
        self.displayData = displayData
        self.lotData = nil
    }

    init(position: Position, lot: PositionLotDisplayData) {
        self.title = "\(position.asset.ticker.ticker).\(position.asset.ticker.exchange.code)"
        self.quantity = lot.quantity
        self.openPrice = lot.openPrice
        self.amount = nil
        self.profit = nil
        self.displayData = nil
        self.lotData = lot
    }
    
    init(position: PositionSnapshot) {
        self.title = "\(position.ticker.ticker).\(position.ticker.exchange.code)"
        self.quantity = position.quantity
        self.openPrice = Self.unitOpenPrice(quantity: position.quantity, openAmount: position.openAmount)
        self.amount = position.price
        self.profit = Amount(
            value: position.price.value - position.openAmount.value,
            currency: position.price.currency
        )
        self.displayData = nil
        self.lotData = nil
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                subtitleView
            }

            Spacer(minLength: 12)

            if let displayData {
                PositionValueStack(
                    convertedAmount: displayData.convertedCurrentAmount,
                    originalAmount: displayData.currentAmount,
                    convertedProfit: displayData.convertedProfit,
                    profitPercent: displayData.profitPercent
                )
            } else if let lotData {
                PositionValueStack(
                    convertedAmount: lotData.convertedCurrentAmount,
                    originalAmount: lotData.currentAmount,
                    convertedProfit: lotData.convertedProfit,
                    profitPercent: lotData.profitPercent
                )
            } else if let amount, let profit {
                LegacyPositionValueStack(amount: amount, profit: profit)
            } else {
                ProgressView()
                    .padding(.vertical, 4)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }

    @ViewBuilder
    private var subtitleView: some View {
        if let openPrice {
            HStack(spacing: 4) {
                Text(quantity, format: .number)

                Text("x")
                    .foregroundStyle(.secondary)

                Text(openPrice.formatted ?? "NaN")
            }
            .font(.subheadline.weight(.medium))
            .foregroundStyle(.secondary)
            .lineLimit(1)
        } else {
            Text(quantity, format: .number)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
    }

    private static func unitOpenPrice(quantity: Double, openAmount: Amount) -> Amount? {
        guard quantity != 0 else {
            return nil
        }

        return Amount(value: openAmount.value / quantity, currency: openAmount.currency)
    }
}

private struct PositionValueStack: View {
    let convertedAmount: Amount
    let originalAmount: Amount
    let convertedProfit: Amount
    let profitPercent: Double?

    var body: some View {
        VStack(alignment: .trailing, spacing: 4) {
            AmountWithOriginalCurrencyView(
                convertedAmount: convertedAmount,
                originalAmount: originalAmount
            )

            ProfitWithOriginalCurrencyView(
                convertedProfit: convertedProfit,
                profitPercent: profitPercent
            )
        }
        .multilineTextAlignment(.trailing)
    }
}

private struct LegacyPositionValueStack: View {
    let amount: Amount
    let profit: Amount

    var body: some View {
        VStack(alignment: .trailing, spacing: 4) {
            AmountView(amount: amount)
                .font(.subheadline.weight(.semibold))
                .lineLimit(1)

            ProfitAmountView(profit: profit)
                .font(.caption.weight(.semibold))
                .lineLimit(1)
        }
        .multilineTextAlignment(.trailing)
    }
}

private struct AmountWithOriginalCurrencyView: View {
    let convertedAmount: Amount
    let originalAmount: Amount

    var body: some View {
        VStack(alignment: .trailing, spacing: 2) {
            AmountView(amount: convertedAmount)
                .font(.subheadline.weight(.semibold))
                .lineLimit(1)

            if convertedAmount.currency != originalAmount.currency {
                Text(originalAmount.formatted ?? "NaN")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
    }
}

private struct ProfitWithOriginalCurrencyView: View {
    let convertedProfit: Amount
    let profitPercent: Double?

    var body: some View {
        HStack(spacing: 4) {
            ProfitAmountView(profit: convertedProfit)

            if let profitPercent {
                Text(formattedPercent(profitPercent))
                    .foregroundStyle(profitColor)
            }
        }
        .font(.caption.weight(.semibold))
        .lineLimit(1)
    }

    private var profitColor: Color {
        if convertedProfit.value > 0 {
            return .green
        } else if convertedProfit.value < 0 {
            return .red
        } else {
            return .secondary
        }
    }

    private func formattedPercent(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.positivePrefix = "+"
        return formatter.string(from: NSNumber(value: value)) ?? "0%"
    }

}

//
//  AmountView.swift
//  longfolio
//
//  Created by Alena Nesterkina on 13.04.2026.
//

import SwiftUI
import SharedModels

struct AmountView: View {
    let amount: Double
    let currency: Currency
    
    var body: some View {
        HStack {
            Text("\(currency.rawValue.uppercased()): ")
                .font(.body.weight(.medium))
            Text(amount, format: .number.precision(.fractionLength(4)))
                .font(.body.weight(.medium))
        }
    }
}

//
//  ProfitAmountView.swift
//  longfolio
//
//  Created by Илья Бочков on 14.04.26.
//

import SwiftUI
import SharedModels

struct ProfitAmountView: View {
    let profit: Amount
    
    var body: some View {
        Text("\(sign)\(profit.formatted ?? "NaN")")
            .foregroundStyle(color)
    }
    
    private var sign: String {
        profit.value > 0 ? "+" : ""
    }
    
    private var color: Color {
        if profit.value > 0 {
            return .green
        } else if profit.value < 0 {
            return .red
        } else {
            return .secondary
        }
    }
}

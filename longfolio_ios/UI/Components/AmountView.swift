//
//  AmountView.swift
//  longfolio
//
//  Created by Илья Бочков on 13.04.26.
//

import SwiftUI
import SharedModels

struct AmountView: View {
    let amount: Amount
    
    var body: some View {
        Text(amount.formatted ?? "NaN")
    }
}

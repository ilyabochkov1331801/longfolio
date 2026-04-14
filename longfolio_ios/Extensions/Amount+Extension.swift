//
//  Amount+Extension.swift
//  longfolio
//
//  Created by Илья Бочков on 14.04.26.
//

import SharedModels
import Foundation

extension Amount {
    var formatted: String? {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.numberStyle = .currency
        formatter.currencyCode = currency.rawValue
        return formatter.string(from: NSNumber(value: value))
    }
}

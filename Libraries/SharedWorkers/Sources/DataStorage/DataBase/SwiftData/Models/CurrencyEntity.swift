//
//  CurrencyEntity.swift
//  SharedWorkers
//
//  Created by Alena Nesterkina on 21.04.2026.
//

import Foundation
import SwiftData
import SharedModels

@Model
final class CurrencyEntity {
    var date: Date
    var base: String
    var quote: String
    var rate: Double

    init(date: Date, base: String, quote: String, rate: Double) {
        self.date = date
        self.base = base
        self.quote = quote
        self.rate = rate
    }
}

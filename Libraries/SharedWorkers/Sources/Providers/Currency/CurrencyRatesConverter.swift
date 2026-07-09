//
//  CurrencyRatesConverter.swift
//  SharedWorkers
//
//  Created by Alena Nesterkina on 21.04.2026.
//

import Foundation
import SharedModels
import SharedNetwork

public protocol ConvertsCurrency {
    func convert(to: Currency, amount: [Amount], date: Date) async throws -> Amount
    func convert(to: Currency, amount: Amount, date: Date) async throws -> Amount
}

public final class CurrencyRatesConverter: ConvertsCurrency {
    private let currencyProvider: ProvidesCurrency
    
    public init(currencyProvider: ProvidesCurrency) {
        self.currencyProvider = currencyProvider
    }
    
    public func convert(to: Currency, amount: [Amount], date: Date) async throws -> Amount {
        var summ = 0.0
        for amt in amount {
            if amt.currency == to {
                summ += amt.value
            } else {
                let rate = try await currencyProvider.getCurrencyRate(from: amt.currency, to: to, date: date)
                summ += amt.value * rate
            }
        }
        
        return Amount(value: summ, currency: to)
    }
    
    public func convert(to: Currency, amount: Amount, date: Date) async throws -> Amount {
        let rate = try await currencyProvider.getCurrencyRate(from: amount.currency, to: to, date: date)
        return Amount(value: amount.value * rate, currency: to)
    }
}

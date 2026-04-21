//
//  CurrencyProvider.swift
//  SharedWorkers
//
//  Created by Alena Nesterkina on 21.04.2026.
//

import Foundation
import SharedModels
import SharedNetwork

public protocol ProvidesCurrency {
    func convert(to: Currency, amount: [Amount]) async throws -> Double
    func convert(from: Currency, to: Currency, amount: Double) async throws -> Double
}

public final class CurrencyProvider: ProvidesCurrency {
    private let eodhdNetworkService: EodhdNetworkServiceProtocol
    private var currencyRates: [String: Double] = [:]
    
    public init(eodhdNetworkService: EodhdNetworkServiceProtocol) {
        self.eodhdNetworkService = eodhdNetworkService
    }
    
    public func convert(to: Currency, amount: [Amount]) async throws -> Double {
        var summ = 0.0
        for amt in amount {
            if amt.currency == to {
                summ += amt.value
            } else {
                let rate = try await getCurrencyRate(from: amt.currency, to: to)
                summ += amt.value * rate
            }
        }
        return summ
    }
    
    public func convert(from: Currency, to: Currency, amount: Double) async throws -> Double {
        let rate = try await getCurrencyRate(from: from, to: to)
        return amount * rate
    }
    
    private func getCurrencyRate(from: Currency, to: Currency) async throws -> Double {
        let pair = "\(from.rawValue)\(to.rawValue)"
        if let rate = currencyRates[pair] {
            return rate
        }
        
        let currencyRate = try await eodhdNetworkService.currencyRate(pair: pair)
        currencyRates[pair] = currencyRate.close
        return currencyRate.close
    }
}

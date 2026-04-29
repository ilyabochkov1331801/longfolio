//
//  CurrencyProvider.swift
//  SharedWorkers
//
//  Created by Alena Nesterkina on 21.04.2026.
//

import Foundation
import SharedModels
import SwiftData
import SharedNetwork

public protocol ProvidesCurrency {
    func getCurrencyRate(from: Currency, to: Currency, date: Date) async throws -> Double
}

@MainActor
public final class CurrencyProvider: ProvidesCurrency {
    private let frankfurterNetworkService: FrankfurterNetworkServiceProtocol
    private let dataBase: SwiftDataBaseProtocol
    
    public init(frankfurterNetworkService: FrankfurterNetworkServiceProtocol, dataBase: SwiftDataBaseProtocol) {
        self.frankfurterNetworkService = frankfurterNetworkService
        self.dataBase = dataBase
    }
    
    public func getCurrencyRate(from: Currency, to: Currency, date: Date) async throws -> Double {
        let descriptor = FetchDescriptor<CurrencyEntity>(
            predicate: #Predicate { $0.base == from.rawValue && $0.quote == to.rawValue }
        )

        
        if let currency = try dataBase.fetch(descriptor: descriptor).first(where: { $0.date.isSameDay(with: date) }) {
            return currency.rate
        }
        
        let currencyRate = try await frankfurterNetworkService.currencyRate(from: from.rawValue, to: to.rawValue, date: date)
        let currencyRateEntity = CurrencyEntity(date: date, base: from.rawValue, quote: to.rawValue, rate: currencyRate.rate)
        dataBase.insert(entity: currencyRateEntity)
        try dataBase.save()
        
        return currencyRate.rate
    }
}

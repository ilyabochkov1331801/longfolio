//
//  Amount.swift
//  SharedModels
//
//  Created by Илья Бочков on 11.03.26.
//

public struct Amount: Equatable, Hashable, Codable {
    public let value: Double
    public let currency: Currency
    
    public init(value: Double, currency: Currency) {
        self.value = value
        self.currency = currency
    }
}

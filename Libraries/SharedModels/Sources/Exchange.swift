//
//  Exchange.swift
//  SharedModels
//
//  Created by Илья Бочков on 1.04.26.
//

public struct Exchange: Equatable, Hashable, Sendable, Codable {
    public let name: String
    public let code: String
    public let country: String
    public let currency: Currency

    public init(name: String, code: String, country: String, currency: Currency) {
        self.name = name
        self.code = code
        self.country = country
        self.currency = currency
    }
}

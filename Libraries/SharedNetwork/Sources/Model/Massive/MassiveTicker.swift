//
//  MassiveTicker.swift
//  SharedNetwork
//
//  Created by Илья Бочков on 24.03.26.
//

import SharedModels

public struct MassiveTicker: Codable, Sendable {
    public let ticker: String
    public let name: String
    public let currency: Currency
    
    enum CodingKeys: String, CodingKey {
        case ticker
        case name
        case currency = "currency_name"
    }
}

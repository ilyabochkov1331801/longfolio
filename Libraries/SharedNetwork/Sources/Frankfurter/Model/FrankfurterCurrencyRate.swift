//
//  FrankfurterCurrencyRate.swift
//  SharedNetwork
//
//  Created by Alena Nesterkina on 21.04.2026.
//

import Foundation

public struct FrankfurterCurrencyRate: Codable, Sendable {
    public let date: Date
    public let base: String
    public let quote: String
    public let rate: Double

    enum CodingKeys: String, CodingKey {
        case date
        case base
        case quote
        case rate
    }
}

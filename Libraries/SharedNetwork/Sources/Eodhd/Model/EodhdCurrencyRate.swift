//
//  EodhdCurrencyRate.swift
//  SharedNetwork
//
//  Created by Alena Nesterkina on 21.04.2026.
//

import Foundation

public struct EodhdCurrencyRate: Codable, Sendable {
    public let code: String
    public let timestamp: Int
    public let gmtoffset: Int
    public let open: Double
    public let high: Double
    public let low: Double
    public let close: Double

    enum CodingKeys: String, CodingKey {
        case code
        case timestamp
        case gmtoffset
        case open
        case high
        case low
        case close
    }
}

//
//  EodhdAssetQuote.swift
//  SharedNetwork
//
//  Created by Assistant on 08.04.26.
//

import Foundation

public struct EodhdRealtimeAssetPrice: Codable, Sendable {
    public let code: String
    public let timestamp: Int
    public let gmtoffset: Int
    public let open: Double
    public let high: Double
    public let low: Double
    public let close: Double
    public let volume: Int
    public let previousClose: Double
    public let change: Double
    public let changePercent: Double

    enum CodingKeys: String, CodingKey {
        case code
        case timestamp
        case gmtoffset
        case open
        case high
        case low
        case close
        case volume
        case previousClose
        case change
        case changePercent = "change_p"
    }
}

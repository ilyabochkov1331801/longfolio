//
//  EodhdAssetDayPrice.swift
//  SharedNetwork
//
//  Created by Илья Бочков on 1.04.26.
//

import Foundation

public struct EodhdAssetDayPrice: Codable, Sendable {
    public let date: Date
    public let open: Double
    public let high: Double
    public let low: Double
    public let close: Double
    public let adjustedClose: Double
    public let volume: Int
    
    enum CodingKeys: String, CodingKey {
        case date
        case open
        case high
        case low
        case close
        case adjustedClose = "adjusted_close"
        case volume
    }
}

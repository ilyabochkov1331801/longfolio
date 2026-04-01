//
//  EodhdAsset.swift
//  SharedNetwork
//
//  Created by Илья Бочков on 1.04.26.
//

import Foundation

public struct EodhdAsset: Codable, Sendable {
    public let code: String
    public let exchange: String
    public let name: String
    public let type: String
    public let country: String
    public let currency: String
    public let isin: String?
    public let previousClose: Double
    public let previousCloseDate: Date
    public let isPrimary: Bool
    
    enum CodingKeys: String, CodingKey {
        case code = "Code"
        case exchange = "Exchange"
        case name = "Name"
        case type = "Type"
        case country = "Country"
        case currency = "Currency"
        case isin = "ISIN"
        case previousClose
        case previousCloseDate
        case isPrimary
    }
}

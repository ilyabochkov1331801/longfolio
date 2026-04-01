//
//  MassiveTickerDayPrice.swift
//  SharedNetwork
//
//  Created by Илья Бочков on 31.03.26.
//

import Foundation

public struct MassiveTickerDayPrice: Codable, Sendable {
    public let symbol: String
    public let close: Double
    public let from: Date
}

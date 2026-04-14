//
//  Currency.swift
//  SharedModels
//
//  Created by Илья Бочков on 11.03.26.
//

public enum Currency: String, Equatable, Hashable, Codable, Sendable, Comparable {
    public static func < (lhs: Currency, rhs: Currency) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
    
    case usd
    case eur
    
    case unknown
}

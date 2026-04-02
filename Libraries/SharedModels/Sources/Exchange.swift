//
//  Exchange.swift
//  SharedModels
//
//  Created by Илья Бочков on 1.04.26.
//

public struct Exchange: Equatable, Hashable  {
    public let name: String
    public let code: String
    public let country: String
    public let currency: Currency
}

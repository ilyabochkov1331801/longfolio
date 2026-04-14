//
//  ExchangeEntity.swift
//  SharedWorkers
//
//  Created by Илья Бочков on 1.04.26.
//

import Foundation
import SwiftData
import SharedModels

@Model
final class ExchangeEntity {
    var name: String
    var code: String
    var country: String
    var currency: Currency
    
    @Relationship(deleteRule: .cascade, inverse: \AssetEntity.exchange)
    var assets: [AssetEntity]
    
    init(name: String, code: String, country: String, currency: Currency, assets: [AssetEntity]) {
        self.name = name
        self.code = code
        self.country = country
        self.currency = currency
        self.assets = assets
    }
}

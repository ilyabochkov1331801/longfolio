//
//  SettingsProvider.swift
//  SharedWorkers
//
//  Created by Alena Nesterkina on 21.04.2026.
//

import SharedModels
import Foundation

public protocol ProvidesSettings {
    func getDefaultCurrency() throws -> Currency
    func setDefaultCurrency(currency: Currency) throws
}

public final class SettingsProvider: ProvidesSettings {
    private let userDefaultsManager: ManagesUserDefaultsData
    
    public init(userDefaultsManager: ManagesUserDefaultsData) {
        self.userDefaultsManager = userDefaultsManager
    }

    public func setDefaultCurrency(currency: Currency) throws {
        try userDefaultsManager.save(item: currency.rawValue, key: .currency)
    }
    
    public func getDefaultCurrency() throws -> Currency {
        try userDefaultsManager.fetchAll(key: .currency)
    }
}

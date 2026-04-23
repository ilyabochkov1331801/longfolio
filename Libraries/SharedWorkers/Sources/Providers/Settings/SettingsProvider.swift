//
//  SettingsProvider.swift
//  SharedWorkers
//
//  Created by Alena Nesterkina on 21.04.2026.
//

import SharedModels
import Foundation
import Combine

public protocol ProvidesSettings {
    var updatesPublisher: AnyPublisher<Void, Never> { get }
    
    func getDefaultCurrency() throws -> Currency
    func setDefaultCurrency(currency: Currency) throws
}

public final class SettingsProvider: ObservableObject, ProvidesSettings {
    private let userDefaultsManager: ManagesUserDefaultsData
    private let updateSubject: PassthroughSubject<Void, Never>
    
    public var updatesPublisher: AnyPublisher<Void, Never> {
        updateSubject.eraseToAnyPublisher()
    }
    
    public init(userDefaultsManager: ManagesUserDefaultsData) {
        self.userDefaultsManager = userDefaultsManager
        self.updateSubject = PassthroughSubject()
        
        setDefaultData()
    }
    
    private func setDefaultData() {
        if let currency = try? getDefaultCurrency() {
            return
        }
        
        try? setDefaultCurrency(currency: .eur)
    }

    public func setDefaultCurrency(currency: Currency) throws {
        try userDefaultsManager.save(item: currency.rawValue, key: .currency)
        updateSubject.send()
    }
    
    public func getDefaultCurrency() throws -> Currency {
        try userDefaultsManager.fetchAll(key: .currency)
    }
}

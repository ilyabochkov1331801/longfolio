//
//  SettingsScreenViewModel.swift
//  longfolio
//
//  Created by Alena Nesterkina on 21.04.2026.
//

import Combine
import SharedWorkers
import SharedModels
import Observation
import Foundation

@Observable
final class SettingsScreenViewModel {
    private let settingsProvider: ProvidesSettings
    
    var defaultCurrency: Currency = .usd {
        didSet {
            updateDefaultCurrency(to: defaultCurrency)
        }
    }
    var errorMessage: String?
    
    init(dependencyContainer: DIContainer) {
        self.settingsProvider = SettingsProvider(userDefaultsManager: dependencyContainer.userDefaultsManager)
        
       setupData()
    }
    
    private func setupData() {
        do {
            try defaultCurrency = settingsProvider.getDefaultCurrency()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func updateDefaultCurrency(to currency: Currency) {
        do {
            try settingsProvider.setDefaultCurrency(currency: currency)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}


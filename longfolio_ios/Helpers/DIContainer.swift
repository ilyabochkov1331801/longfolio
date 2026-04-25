//
//  DIContainer.swift
//  longfolio
//
//  Created by Илья Бочков on 2.04.26.
//

import Foundation
import Combine
import SharedNetwork
import SharedWorkers

final class DIContainer: ObservableObject {
    let contextManager: ManagesSwiftDataContext
    let eodhdNetworkService: EodhdNetworkServiceProtocol
    let frankfurterNetworkService: FrankfurterNetworkServiceProtocol
    let realtimePriceCache: RealtimePriceCache
    let userDefaultsManager: ManagesUserDefaultsData
    let settingsProvider: SettingsProvider
    let currencyProvider: ProvidesCurrency
    let converter: ConvertsCurrency
    
    init() {
        do {
            contextManager = try SwiftDataContextManager.createDefault()
            eodhdNetworkService = EodhdNetworkService()
            frankfurterNetworkService = FrankfurterNetworkService()
            realtimePriceCache = RealtimePriceCache()
            userDefaultsManager = UserDefaultsManager()
            settingsProvider = SettingsProvider(userDefaultsManager: userDefaultsManager)
            currencyProvider = CurrencyProvider(frankfurterNetworkService: frankfurterNetworkService, dataBase: SwiftDataBase(contextManager: contextManager))
            converter = CurrencyRatesConverter(currencyProvider: currencyProvider)
        } catch {
            fatalError("Failed to initialize dependencies: \(error.localizedDescription)")
        }
    }
}

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
    
    init() {
        do {
            contextManager = try SwiftDataContextManager.createDefault()
            eodhdNetworkService = EodhdNetworkService()
        } catch {
            fatalError("Failed to initialize dependencies: \(error.localizedDescription)")
        }
    }
}

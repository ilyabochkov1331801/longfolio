//
//  DIContainer.swift
//  longfolio
//
//  Created by Илья Бочков on 2.04.26.
//

import Foundation
import Combine
import SharedWorkers

final class DIContainer: ObservableObject {
    let contextManager: ManagesSwiftDataContext
    
    init() {
        do {
            contextManager = try SwiftDataContextManager.createDefault()
        } catch {
            fatalError("Failed to initialize dependencies: \(error.localizedDescription)")
        }
    }
}

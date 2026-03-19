//
//  SwiftDataContextManager.swift
//  SharedWorkers
//
//  Created by Alena Nesterkina on 16.03.26.
//

import Foundation
import SwiftData

public protocol ManagesSwiftDataContext: AnyObject {
    var container: ModelContainer { get }
    @MainActor
    var mainContext: ModelContext { get }
    
    func makeContext() -> ModelContext
}

public final class SwiftDataContextManager: ManagesSwiftDataContext {
    public let container: ModelContainer
    
    @MainActor
    public lazy var mainContext: ModelContext = {
        ModelContext(container)
    }()
    
    public init(models: [any PersistentModel.Type]) throws {
        let schema = Schema(models)
        container = try ModelContainer(for: schema)
    }
    
    public func makeContext() -> ModelContext {
        ModelContext(container)
    }
}

//
//  SwiftDataBase.swift
//  SharedWorkers
//
//  Created by Alena Nesterkina on 17.03.26.
//

import SwiftData

@MainActor
public protocol SwiftDataBaseProtocol {
    func fetch<T: PersistentModel>(descriptor: FetchDescriptor<T>) throws -> [T]
    func insert<T: PersistentModel>(entity: T)
    func delete<T: PersistentModel>(entity: T)
    func save() throws
}

public final class SwiftDataBase: SwiftDataBaseProtocol {
    private let contextManager: ManagesSwiftDataContext
    
    public init(contextManager: ManagesSwiftDataContext) {
        self.contextManager = contextManager
    }
    
    public func fetch<T: PersistentModel>(descriptor: FetchDescriptor<T>) throws -> [T] {
        try contextManager.context.fetch(descriptor)
    }
    
    public func insert<T: PersistentModel>(entity: T) {
        contextManager.context.insert(entity)
    }
    
    public func delete<T: PersistentModel>(entity: T) {
        contextManager.context.delete(entity)
    }
    
    public func save() throws {
        try contextManager.context.save()
    }
}

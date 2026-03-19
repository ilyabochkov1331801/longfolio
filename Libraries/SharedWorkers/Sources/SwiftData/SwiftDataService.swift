//
//  SwiftDataService.swift
//  SharedWorkers
//
//  Created by Alena Nesterkina on 17.03.26.
//

import Foundation
import SwiftData

protocol StorageOperations {
    associatedtype Entity: PersistentModel
    
    func fetch(_ descriptor: FetchDescriptor<Entity>) throws -> [Entity]
    func insert(_ entity: Entity) throws
    func delete(_ entity: Entity) throws
    func save() throws
}

final class SwiftDataService<Entity: PersistentModel>: StorageOperations {
    private let context: ModelContext
    
    init(context: ModelContext) {
        self.context = context
    }
    
    func fetch(_ descriptor: FetchDescriptor<Entity>) throws -> [Entity] {
        try context.fetch(descriptor)
    }
    
    func insert(_ entity: Entity) throws {
        context.insert(entity)
        try save()
    }
    
    func delete(_ entity: Entity) throws {
        context.delete(entity)
        try save()
    }
    
    func save() throws {
        try context.save()
    }
}

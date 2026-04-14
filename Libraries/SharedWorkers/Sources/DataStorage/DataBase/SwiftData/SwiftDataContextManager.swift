//
//  SwiftDataContextManager.swift
//  SharedWorkers
//
//  Created by Alena Nesterkina on 16.03.26.
//

import Foundation
import Combine
import SwiftData

public protocol ManagesSwiftDataContext: AnyObject {
    var context: ModelContext { get }
    var updatesPublisher: AnyPublisher<Notification, Never> { get }
}

public final class SwiftDataContextManager: ManagesSwiftDataContext {
    private let container: ModelContainer
    public let context: ModelContext
    public let updatesPublisher: AnyPublisher<Notification, Never>

    public init(models: [any PersistentModel.Type]) throws {
        self.container = try ModelContainer(for: Schema(models))
        self.context = ModelContext(container)
        self.updatesPublisher = NotificationCenter.default
            .publisher(for: ModelContext.didSave, object: context)
            .eraseToAnyPublisher()
    }
    
    public static func createDefault() throws -> SwiftDataContextManager {
        try SwiftDataContextManager(
            models: [
                AssetEntity.self,
                AssetDayPriceEntity.self,
                AssetTransactionEntity.self,
                CashTransactionEntity.self,
                DividendTransactionEntity.self,
                ExchangeEntity.self,
                PortfolioEntity.self,
                PositionEntity.self,
                PositionSnapshotEntity.self,
                PortfolioSnapshotEntity.self
            ]
        )
    }
}

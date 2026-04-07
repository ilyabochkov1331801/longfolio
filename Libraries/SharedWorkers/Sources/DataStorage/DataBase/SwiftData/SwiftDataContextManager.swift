//
//  SwiftDataContextManager.swift
//  SharedWorkers
//
//  Created by Alena Nesterkina on 16.03.26.
//

import Foundation
import SwiftData

public protocol ManagesSwiftDataContext: AnyObject {
    var context: ModelContext { get }
}

public final class SwiftDataContextManager: ManagesSwiftDataContext {
    private let container: ModelContainer
    public let context: ModelContext

    public init(models: [any PersistentModel.Type]) throws {
        self.container = try ModelContainer(for: Schema(models))
        self.context = ModelContext(container)
    }
    
    public static func createDefault() throws -> SwiftDataContextManager {
        try SwiftDataContextManager(
            models: [
                AssetEntity.self,
                AssetTickerEntity.self,
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

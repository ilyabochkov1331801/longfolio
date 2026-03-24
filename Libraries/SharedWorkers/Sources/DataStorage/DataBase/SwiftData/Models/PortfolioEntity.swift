//
//  PortfolioEntity.swift
//  SharedWorkers
//
//  Created by Илья Бочков on 20.03.26.
//

import Foundation
import SwiftData
import SharedModels

@Model
final class PortfolioEntity {
    @Attribute(.unique)
    var name: String
    
    @Relationship(deleteRule: .cascade, inverse: \AssetTransactionEntity.portfolio)
    var assetsTransactions: [AssetTransactionEntity]
    
    @Relationship(deleteRule: .cascade, inverse: \DividendTransactionEntity.portfolio)
    var dividendTransactions: [DividendTransactionEntity]
    
    @Relationship(deleteRule: .cascade, inverse: \CashTransactionEntity.portfolio)
    var cashTransactions: [CashTransactionEntity]
    
    @Relationship(deleteRule: .cascade, inverse: \PositionEntity.portfolio)
    var positions: [PositionEntity]
    
    @Relationship(deleteRule: .cascade, inverse: \PortfolioSnapshotEntity.portfolio)
    var snapshots: [PortfolioSnapshotEntity]
    
    init(
        name: String,
        assetsTransactions: [AssetTransactionEntity],
        dividendTransactions: [DividendTransactionEntity],
        cashTransactions: [CashTransactionEntity],
        positions: [PositionEntity],
        snapshots: [PortfolioSnapshotEntity]
    ) {
        self.name = name
        self.assetsTransactions = assetsTransactions
        self.dividendTransactions = dividendTransactions
        self.cashTransactions = cashTransactions
        self.positions = positions
        self.snapshots = snapshots
    }
}

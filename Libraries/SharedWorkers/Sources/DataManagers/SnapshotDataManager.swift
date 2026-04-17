//
//  SnapshotDataManager.swift
//  SharedWorkers
//
//  Created by Alena Nesterkina on 17.04.2026.
//

import Foundation
import SwiftData
import SharedModels
import SharedNetwork

public protocol ManagesSnapshotData {
    func getOrFetchSnapshot(for date: Date, portfolio: Portfolio) throws -> PortfolioSnapshot
    func fetchPortfolioSnapshot(with name: String, for date: Date) throws -> PortfolioSnapshot?
    func createNewPortfolioSnapshot(with name: String, portfolio: Portfolio) throws
    func deletePortfolioSnapshot(with name: String) throws
}

public final class SnapshotDataManager: ManagesSnapshotData {
    private let eodhdNetworkService: EodhdNetworkServiceProtocol
    private let dataBase: SwiftDataBaseProtocol
    private let mapper: SwiftDataModelsMapper

    public init(dataBase: SwiftDataBaseProtocol, networkService: EodhdNetworkServiceProtocol) {
        self.dataBase = dataBase
        self.eodhdNetworkService = networkService
        self.mapper = SwiftDataModelsMapper()
    }
    
    public func getOrFetchSnapshot(for date: Date, portfolio: Portfolio) throws -> PortfolioSnapshot {
        let filteredTransactions = portfolio.assetsTransactions.filter({ $0.date <= date })
        let posotionsDic: [Position: ]
    }

    public func createNewPortfolioSnapshot(with name: String, portfolio: Portfolio) throws {
        let portfolioEntity = try fetchOrCreatePortfolio(from: portfolio)
        let portfolioSnapshot = PortfolioSnapshotEntity(
            positions: [],
            date: Date(),
            name: name,
            cache: [],
            portfolio: portfolioEntity
        )

        dataBase.insert(entity: portfolioSnapshot)
        try dataBase.save()
    }

    public func deletePortfolioSnapshot(with name: String) throws {
        let descriptor = FetchDescriptor<PortfolioSnapshotEntity>(
            predicate: #Predicate { $0.name == name }
        )

        guard let portfolioSnapshot = try dataBase.fetch(descriptor: descriptor).first else {
            return
        }

        dataBase.delete(entity: portfolioSnapshot)
        try dataBase.save()
    }
    
    private func fetchOrCreatePortfolio(from portfolio: Portfolio) throws -> PortfolioEntity {
        let descriptor = FetchDescriptor<PortfolioEntity>(
            predicate: #Predicate { $0.name == portfolio.name }
        )

        if let existingPortfolio = try dataBase.fetch(descriptor: descriptor).first {
            return existingPortfolio
        }

        throw PortfolioNotFoundError()
    }
}

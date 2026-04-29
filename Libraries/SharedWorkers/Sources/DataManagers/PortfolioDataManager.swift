//
//  PortfolioStorage.swift
//  SharedWorkers
//
//  Created by Assistant on 06.04.26.
//

import Foundation
import SwiftData
import SharedModels

@MainActor
public protocol ManagesPortfolioData {
    func fetchPortfolios() throws -> [Portfolio]
    func fetchPortfolio(with name: String) throws -> Portfolio?
    func createNewPortfolio(with name: String) throws
    func deletePortfolio(with name: String) throws
}

public final class PortfolioDataManager: ManagesPortfolioData {
    private let dataBase: SwiftDataBaseProtocol
    private let mapper: SwiftDataModelsMapper

    public init(dataBase: SwiftDataBaseProtocol) {
        self.dataBase = dataBase
        self.mapper = SwiftDataModelsMapper()
    }

    public func fetchPortfolios() throws -> [Portfolio] {
        let descriptor = FetchDescriptor<PortfolioEntity>(
            sortBy: [SortDescriptor(\.name)]
        )

        return try dataBase.fetch(descriptor: descriptor).map(mapper.makePortfolio)
    }

    public func fetchPortfolio(with name: String) throws -> Portfolio? {
        let descriptor = FetchDescriptor<PortfolioEntity>(
            predicate: #Predicate { $0.name == name }
        )

        return try dataBase.fetch(descriptor: descriptor).first.map(mapper.makePortfolio)
    }

    public func createNewPortfolio(with name: String) throws {
        let portfolio = PortfolioEntity(
            name: name,
            cashAmount: [],
            buyAssetsTransactions: [],
            sellAssetsTransactions: [],
            dividendTransactions: [],
            cashTransactions: [],
            positions: [],
            snapshots: []
        )

        dataBase.insert(entity: portfolio)
        try dataBase.save()
    }

    public func deletePortfolio(with name: String) throws {
        let descriptor = FetchDescriptor<PortfolioEntity>(
            predicate: #Predicate { $0.name == name }
        )

        guard let portfolio = try dataBase.fetch(descriptor: descriptor).first else {
            return
        }

        dataBase.delete(entity: portfolio)
        try dataBase.save()
    }
}

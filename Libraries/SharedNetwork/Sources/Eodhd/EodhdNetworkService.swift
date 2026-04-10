//
//  EodhdNetworkService.swift
//  SharedNetwork
//
//  Created by Илья Бочков on 1.04.26.
//

import Alamofire
import Foundation

public protocol EodhdNetworkServiceProtocol: NetworkService {
    func searchAssets(for query: String) async throws -> [EodhdAsset]
    func assetPrices(
        for ticker: String, exchange: String, fromDate: Date, toDate: Date
    ) async throws -> [EodhdAssetDayPrice]
    func realTimeAssetPrice(for ticker: String, exchange: String) async throws -> EodhdRealtimeAssetPrice
}

public final class EodhdNetworkService: NetworkServiceTrait, EodhdNetworkServiceProtocol {
    private let dateFormatter: DateFormatter

    public let decoder: DataDecoder
    
    public init() {
        let jsonDecoder = JSONDecoder()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        self.dateFormatter = dateFormatter
        jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)
        decoder = jsonDecoder
    }
    
    public func searchAssets(for query: String) async throws -> [EodhdAsset] {
        try await execute(request: EodhdEndpoint.searchAssets(query: query))
    }
    
    public func assetPrices(
        for ticker: String, exchange: String, fromDate: Date, toDate: Date
    ) async throws -> [EodhdAssetDayPrice] {
        let from = dateFormatter.string(from: fromDate)
        let to = dateFormatter.string(from: toDate)
        
        return try await execute(
            request: EodhdEndpoint.assetPrices(ticker: ticker, exchange: exchange, from: from, to: to)
        )
    }
    
    public func realTimeAssetPrice(for ticker: String, exchange: String) async throws -> EodhdRealtimeAssetPrice {
        try await execute(
            request: EodhdEndpoint.realtimeAssetPrice(ticker: ticker, exchange: exchange)
        )
    }
}

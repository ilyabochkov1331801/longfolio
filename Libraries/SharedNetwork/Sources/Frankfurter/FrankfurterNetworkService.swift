//
//  FrankfurterNetworkService.swift
//  SharedNetwork
//
//  Created by Alena Nesterkina on 21.04.2026.
//

import Alamofire
import Foundation

public protocol FrankfurterNetworkServiceProtocol: Sendable, NetworkService {
    func currencyRate(from: String, to: String, date: Date) async throws -> FrankfurterCurrencyRate
}

public final class FrankfurterNetworkService: NetworkServiceTrait, FrankfurterNetworkServiceProtocol {
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
    
    public func currencyRate(from: String, to: String, date: Date) async throws -> FrankfurterCurrencyRate {
        let forDate = dateFormatter.string(from: date)
        
        return try await execute(request: FrankfurterEndpoint.currencyRate(from: from, to: to, date: forDate)).value
    }
}

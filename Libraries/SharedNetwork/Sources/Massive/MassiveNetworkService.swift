//
//  MassiveNetworkService.swift
//  SharedNetwork
//
//  Created by Илья Бочков on 31.03.26.
//

import Alamofire
import Foundation

public protocol MassiveNetworkServiceProtocol: NetworkService {
    func getTickerPrice(ticker: String, date: Date) async throws -> MassiveTickerDayPrice
}

public final class MassiveNetworkService: NetworkServiceTrait {
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
    
    public func getTickerPrice(ticker: String, date: Date) async throws -> MassiveTickerDayPrice {
        try await execute(
            request: MassiveEndpoint.getDayPrice(ticker: ticker, date: dateFormatter.string(from: date))
        )
    }
}

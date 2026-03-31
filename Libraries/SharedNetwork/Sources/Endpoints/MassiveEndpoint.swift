//
//  MassiveEndpoint.swift
//  SharedNetwork
//
//  Created by Илья Бочков on 24.03.26.
//

import Foundation
import Alamofire

public extension NetworkService {
    func getTickers(tickerQuery: String) async throws -> MassiveTickersList {
        try await execute(request: MassiveEndpoint.getTickers(tickerQuery: tickerQuery))
    }
}

enum MassiveEndpoint: URLRequestConvertible {
    case getTickers(tickerQuery: String)
    
    func asURLRequest() throws -> URLRequest {
        let url = try Constants.endpoint.asURL()
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.httpMethod = method.rawValue
        
        let encoding: ParameterEncoding = {
            switch method {
            case .get:
                return URLEncoding.default
            default:
                return JSONEncoding.default
            }
        }()

        return try encoding.encode(urlRequest, with: parameters)
    }
}

private extension MassiveEndpoint {
    var method: HTTPMethod {
        switch self {
        case .getTickers:
            return .get
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case let .getTickers(tickerQuery: tickerQuery):
            return [
                "ticker": tickerQuery,
                "apiKey": Constants.apiKey
            ]
        }
    }
    
    var path: String {
        switch self {
        case let .getTickers(tickerQuery: tickerQuery):
            return "/v3/reference/tickers"
        }
    }
}

fileprivate enum Constants {
    static let apiKey = "oabp6GId87AoHdm6mMGdwD0bO_0fjmM2"
    static let endpoint = "https://api.massive.com"
}

//
//  EodhdEndpoint.swift
//  SharedNetwork
//
//  Created by Илья Бочков on 1.04.26.
//

import Foundation
import Alamofire

enum EodhdEndpoint: URLRequestConvertible {
    case searchAssets(query: String)
    case assetPrices(ticker: String, exchange: String, from: String, to: String)
    case realtimeAssetPrice(ticker: String, exchange: String)
    
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

private extension EodhdEndpoint {
    var method: HTTPMethod {
        switch self {
        case .searchAssets, .realtimeAssetPrice, .assetPrices:
            return .get
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .searchAssets, .realtimeAssetPrice:
            return [
                "api_token": Constants.apiToken,
                "fmt": "json"
            ]
        case let .assetPrices(_, _, from, to):
            return [
                "api_token": Constants.apiToken,
                "from": from,
                "to": to,
                "fmt": "json"
            ]
        }
    }
    
    var path: String {
        switch self {
        case let .searchAssets(query):
            return "/search/\(query)"
        case let .assetPrices(ticker, exchange, _, _):
            return "/eod/\(ticker).\(exchange)"
        case let .realtimeAssetPrice(ticker, exchange):
            return "/real-time/\(ticker).\(exchange)"
        }
    }
}

fileprivate enum Constants {
    // DEMO only works for AAPL.US, TSLA.US , VTI.US, AMZN.US, BTC-USD tickers
    // static let apiToken = "demo"
    static let apiToken = "69cc371c468066.79063897"
    static let endpoint = "https://eodhd.com/api"
}

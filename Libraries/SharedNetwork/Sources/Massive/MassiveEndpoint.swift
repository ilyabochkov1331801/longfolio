//
//  MassiveEndpoint.swift
//  SharedNetwork
//
//  Created by Илья Бочков on 24.03.26.
//

import Foundation
import Alamofire

enum MassiveEndpoint: URLRequestConvertible {
    case getDayPrice(ticker: String, date: String)
    
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
        case .getDayPrice:
            return .get
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .getDayPrice:
            return [
                "apiKey": Constants.apiKey
            ]
        }
    }
    
    var path: String {
        switch self {
        case let .getDayPrice(ticker, date):
            return "/v1/open-close/\(ticker)/\(date)"
        }
    }
}

fileprivate enum Constants {
    static let apiKey = "oabp6GId87AoHdm6mMGdwD0bO_0fjmM2"
    static let endpoint = "https://api.massive.com"
}

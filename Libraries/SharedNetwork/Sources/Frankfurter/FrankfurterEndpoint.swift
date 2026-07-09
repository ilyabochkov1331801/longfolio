//
//  FrankfurterEndpoint.swift
//  SharedNetwork
//
//  Created by Alena Nesterkina on 21.04.2026.
//

import Foundation
import Alamofire

enum FrankfurterEndpoint: URLRequestConvertible {
    case currencyRate(from: String, to: String, date: String)
    
    func asURLRequest() throws -> URLRequest {
        let baseURL = try Constants.endpoint.asURL()
        
        var components = URLComponents(
            url: baseURL.appendingPathComponent(path),
            resolvingAgainstBaseURL: false
        )
        
        components?.queryItems = queryItems
        
        guard let url = components?.url else {
            throw AFError.invalidURL(url: Constants.endpoint)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        return request
    }
}

private extension FrankfurterEndpoint {
    var method: HTTPMethod {
        switch self {
        case .currencyRate:
            return .get
        }
    }
    
    var path: String {
        switch self {
        case .currencyRate(let from, let to, _):
            return "v2/rate/\(from)/\(to)"
        }
    }

    var queryItems: [URLQueryItem]? {
        switch self {
        case .currencyRate(_, _, let date):
            return [
                URLQueryItem(name: "date", value: date)
            ]
        }
    }
}

fileprivate enum Constants {
    static let endpoint = "https://api.frankfurter.dev"
}

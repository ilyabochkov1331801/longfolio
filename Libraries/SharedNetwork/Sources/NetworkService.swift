//
//  NetworkService.swift
//  SharedNetwork
//
//  Created by Илья Бочков on 24.03.26.
//

import Alamofire

public final class NetworkService {
    public init() { }
    
    func execute<T: Decodable & Sendable>(request: URLRequestConvertible) async throws -> T {
        try await AF
            .request(request)
            .cURLDescription {
                print("CURL \($0)")
            }
            .validate()
            .serializingDecodable()
            .value
    }
}

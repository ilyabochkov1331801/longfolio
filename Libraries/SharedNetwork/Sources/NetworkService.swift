//
//  NetworkService.swift
//  SharedNetwork
//
//  Created by Илья Бочков on 24.03.26.
//

import Alamofire
import Foundation

public protocol NetworkService {
    var decoder: DataDecoder { get }
    
    func execute<T: Decodable & Sendable>(request: URLRequestConvertible) -> Task<T, Error>
}

public protocol NetworkServiceTrait: NetworkService { }

public extension NetworkServiceTrait {
    var decoder: DataDecoder { JSONDecoder() }
    
    func execute<T: Decodable & Sendable>(request: URLRequestConvertible) async throws -> T {
        try await AF
            .request(request)
            .cURLDescription {
                print("CURL \($0)")
            }
            .validate()
            .serializingDecodable(decoder: decoder)
            .value
    }
    
    func execute<T: Decodable & Sendable>(request: URLRequestConvertible) -> Task<T, Error> {
        let dataTask = AF
            .request(request)
            .cURLDescription {
                print("CURL \($0)")
            }
            .validate()
            .serializingDecodable(T.self, decoder: decoder)
        
        return Task {
            try await dataTask.value
        }
    }
}

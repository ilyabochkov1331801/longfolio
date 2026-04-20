//
//  Collection+Extension.swift
//  SharedWorkers
//
//  Created by Илья Бочков on 17.04.26.
//

extension Collection {
    func asyncMap<T>(transform: (Element) async throws -> T) async rethrows -> [T] {
        var result: [T] = []
        for element in self {
            let res = try await transform(element)
            result.append(res)
        }
        
        return result
    }
}

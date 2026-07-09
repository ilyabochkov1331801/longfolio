//
//  Collection+Extension.swift
//  SharedWorkers
//
//  Created by Илья Бочков on 17.04.26.
//

extension Collection {
    @MainActor
    func asyncMap<T>(transform: @MainActor (Element) async throws -> T) async rethrows -> [T] {
        var result: [T] = []
        for element in self {
            let res = try await transform(element)
            result.append(res)
        }
        
        return result
    }
}

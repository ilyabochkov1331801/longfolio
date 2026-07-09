//
//  UserDefaultsManager.swift
//  SharedWorkers
//
//  Created by Alena Nesterkina on 21.04.2026.
//

import Foundation

public enum UserDefaultsError: Error {
    case dataCannotBeEncoded
    case dataCannotBeDecoded
    case dataNotFound
}

public enum UserDefaultsKey: String {
    case currency = "currency"
}

public protocol ManagesUserDefaultsData {
    func save<T: Codable>(item: T, key: UserDefaultsKey) throws
    func fetchAll<T: Codable>(key: UserDefaultsKey) throws -> T
    func removeAll(key: UserDefaultsKey)
}

public final class UserDefaultsManager: ManagesUserDefaultsData {
    private let userDefaults: UserDefaults = .standard
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    public init(decoder: JSONDecoder = .init(), encoder: JSONEncoder = .init()) {
        self.decoder = decoder
        self.encoder = encoder
    }
    
    public func save<T>(item: T, key: UserDefaultsKey) throws where T : Codable {
        do {
            let data = try encoder.encode(item)
            userDefaults.set(data, forKey: key.rawValue)
        } catch {
            throw UserDefaultsError.dataCannotBeEncoded
        }
    }
    
    public func fetchAll<T: Codable>(key: UserDefaultsKey) throws -> T {
        guard let data = userDefaults.data(forKey: key.rawValue) else {
            throw UserDefaultsError.dataNotFound
        }
        
        do {
            let item = try decoder.decode(T.self, from: data)
            return item
        } catch {
            throw UserDefaultsError.dataCannotBeDecoded
        }
    }
    
    public func removeAll(key: UserDefaultsKey) {
        userDefaults.removeObject(forKey: key.rawValue)
    }
}

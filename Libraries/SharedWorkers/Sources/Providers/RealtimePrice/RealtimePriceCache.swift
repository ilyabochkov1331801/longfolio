//
//  RealtimePriceCache.swift
//  SharedWorkers
//
//  Created by Илья Бочков on 14.04.26.
//

import SharedModels

public actor RealtimePriceCache {
    private var storage: [AssetTicker: Amount] = [:]
    private var inFlight: [AssetTicker: Task<Amount, Error>] = [:]
    
    public init() { }
    
    func setTask(for ticker: AssetTicker, task: Task<Amount, Error>) {
        inFlight[ticker] = task
    }
    
    func getTask(for ticker: AssetTicker) -> Task<Amount, Error>? {
        inFlight[ticker]
    }
    
    func removeTask(for ticker: AssetTicker) {
        inFlight[ticker] = nil
    }
    
    func get(for ticker: AssetTicker) -> Amount? {
        storage[ticker]
    }
    
    func set(_ price: Amount, for ticker: AssetTicker) {
        storage[ticker] = price
    }
}

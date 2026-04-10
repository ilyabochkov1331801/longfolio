//
//  RealtimeAssetPrice.swift
//  SharedModels
//
//  Created by Alena Nesterkina on 10.04.2026.
//

public struct RealtimeAssetPrice: Equatable, Hashable  {
    public let ticker: AssetTicker
    public let close: Double
    
    public init(ticker: AssetTicker, close: Double) {
        self.ticker = ticker
        self.close = close
    }
}

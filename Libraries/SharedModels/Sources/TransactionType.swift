//
//  TransactionType.swift
//  SharedModels
//
//  Created by Илья Бочков on 20.03.26.
//

public enum TransactionType: Equatable, Hashable, Codable {
    case dividend
    case replenishment
    case withdrawal
    case asset(AssetTransactionType)
}

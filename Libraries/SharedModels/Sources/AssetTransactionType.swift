//
//  AssetTransactionType.swift
//  SharedModels
//
//  Created by Илья Бочков on 20.03.26.
//

public enum AssetTransactionType: Equatable, Hashable, Codable, Sendable {
    case buy
    case sell(profit: Amount, closedLots: [AssetLot])
}

public extension AssetTransactionType {
    var isSell: Bool {
        if case .sell = self {
            return true
        }
        return false
    }

    var realizedProfit: Amount? {
        switch self {
        case .buy:
            return nil
        case let .sell(profit, _):
            return profit
        }
    }

    var closedLots: [AssetLot] {
        switch self {
        case .buy:
            return []
        case let .sell(_, closedLots):
            return closedLots
        }
    }

    var closedQuantity: Double {
        closedLots.reduce(0) { $0 + $1.quantity }
    }

    var closedOpenAmount: Amount? {
        guard let currency = closedLots.first?.openAmount.currency else {
            return nil
        }

        return Amount(
            value: closedLots.reduce(0) { $0 + $1.openAmount.value },
            currency: currency
        )
    }
}

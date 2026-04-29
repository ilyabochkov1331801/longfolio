//
//  SwiftDataModelsMapper.swift
//  SharedWorkers
//
//  Created by Assistant on 06.04.26.
//

import Foundation
import SharedModels

final class SwiftDataModelsMapper {
    func makePortfolio(from entity: PortfolioEntity) -> Portfolio {
        Portfolio(
            name: entity.name,
            cashAmount: entity.cashAmount,
            assetsTransactions: entity.buyAssetsTransactions.map(makeBuyAssetTransaction) + entity.sellAssetsTransactions.map(makeSellAssetTransaction),
            cashTransactions: entity.cashTransactions.map(makeCashTransaction),
            dividendsTransactions: entity.dividendTransactions.map(makeDividendTransaction),
            positions: entity.positions.map(makePosition),
            snaphots: entity.snapshots.map(makePortfolioSnapshot)
        )
    }

    func makeAsset(from entity: AssetEntity) -> Asset {
        Asset(
            ticker: AssetTicker(ticker: entity.ticker, exchange: makeExchange(from: entity.exchange)),
            currency: entity.currency,
            priceHistory: entity.priceHistory.map(makeAssetDayPrice)
        )
    }

    func makeBuyAssetTransaction(from entity: BuyAssetTransactionEntity) -> AssetTransaction {
        AssetTransaction(
            id: entity.id,
            date: entity.date,
            type: .buy,
            quantity: entity.quantity,
            amount: entity.amount,
            commision: entity.commision,
            asset: makeAsset(from: entity.asset)
        )
    }
    
    func makeSellAssetTransaction(from entity: SellAssetTransactionEntity) -> AssetTransaction {
        AssetTransaction(
            id: entity.id,
            date: entity.date,
            type: .sell(profit: entity.profit, closedLots: entity.closedLots.map(makeAssetLot)),
            quantity: entity.quantity,
            amount: entity.amount,
            commision: entity.commision,
            asset: makeAsset(from: entity.asset)
        )
    }

    func makeCashTransaction(from entity: CashTransactionEntity) -> CashTransaction {
        CashTransaction(
            id: entity.id,
            date: entity.date,
            amount: entity.amount
        )
    }

    func makeDividendTransaction(from entity: DividendTransactionEntity) -> DividendTransaction {
        DividendTransaction(
            id: entity.id,
            date: entity.date,
            asset: makeAsset(from: entity.asset),
            amount: entity.amount,
            paidTaxes: entity.paidTaxes
        )
    }

    func makePosition(from entity: PositionEntity) -> Position {
        Position(
            asset: makeAsset(from: entity.asset),
            lots: entity.lots.map(makeAssetLot)
        )
    }
    
    func makeAssetLot(from entity: AssetLotEntity) -> AssetLot {
        AssetLot(
            id: entity.id,
            date: entity.date,
            asset: makeAsset(from: entity.asset),
            quantity: entity.quantity,
            openAmount: entity.openAmount
        )
    }

    func makePortfolioSnapshot(from entity: PortfolioSnapshotEntity) -> PortfolioSnapshot {
        PortfolioSnapshot(
            positions: entity.positions.map(makePositionSnapshot),
            date: entity.date,
            name: entity.name,
            cache: entity.cache
        )
    }

    func makePositionSnapshot(from entity: PositionSnapshotEntity) -> PositionSnapshot {
        PositionSnapshot(
            ticker: entity.asset,
            quantity: entity.quantity,
            price: entity.price,
            openAmount: entity.openAmount
        )
    }

    func makeAssetDayPrice(from entity: AssetDayPriceEntity) -> AssetDayPrice {
        AssetDayPrice(date: entity.date, price: entity.price)
    }

    func makeExchange(from entity: ExchangeEntity) -> Exchange {
        Exchange(
            name: entity.name,
            code: entity.code,
            country: entity.country,
            currency: entity.currency
        )
    }
}

//
//  CashTransactionEntity.swift
//  SharedModels
//
//  Created by Alena Nesterkina on 24.03.26.
//

import Foundation

public struct CashTransaction {
    let id: String
    let date: Date
    let amount: Amount
    let portfolio: Portfolio?
}

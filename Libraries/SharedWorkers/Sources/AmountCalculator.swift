//
//  AmountCalculator.swift
//  SharedWorkers
//
//  Created by Илья Бочков on 13.04.26.
//

import SharedModels

public struct AmountCalculator {
    public static func sum(of amounts: [Amount]) -> [Amount] {
        Array(
            amounts.reduce(into: [Currency: Amount]()) { result, element in
                result[element.currency] = Amount(
                    value: (result[element.currency]?.value ?? 0) + element.value,
                    currency: element.currency
                )
            }.values
        )
    }
    
    public static func difference(of amounts: [Amount], taken: [Amount]) -> [Amount] {
        var result: [Currency: Amount] = [:]
        result = amounts.reduce(into: result) { result, element in
            result[element.currency] = Amount(
                value: (result[element.currency]?.value ?? 0) + element.value,
                currency: element.currency
            )
        }
        
        return Array(
            taken.reduce(into: result) { result, element in
                result[element.currency] = Amount(
                    value: (result[element.currency]?.value ?? 0) - element.value,
                    currency: element.currency
                )
            }.values
        )
    }
}

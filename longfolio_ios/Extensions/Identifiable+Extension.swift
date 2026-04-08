//
//  Identifiable+Extension.swift
//  longfolio
//
//  Created by Илья Бочков on 7.04.26.
//

extension Identifiable where Self: Hashable {
    var id: Int { hashValue }
}

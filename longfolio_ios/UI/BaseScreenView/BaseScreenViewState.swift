//
//  BaseViewState.swift
//  longfolio
//
//  Created by Илья Бочков on 2.04.26.
//

import SwiftUI

enum BaseScreenViewState<Model: Equatable>: Equatable {
    static func == (lhs: BaseScreenViewState<Model>, rhs: BaseScreenViewState<Model>) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading):
            return true
        case (.error, .error):
            return true
        case let (.normal(lhsModel), .normal(rhsModel)):
            return lhsModel == rhsModel
        default:
            return false
        }
    }
    
    case loading
    case overlayLoading(Model)
    case error(Error)
    case normal(Model)
}

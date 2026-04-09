//
//  SearchAssetsForTransactionScreenRouter.swift
//  longfolio
//
//  Created by Assistant on 08.04.26.
//

import Foundation
import SharedModels

enum SearchAssetsForTransactionScreenRoute: Hashable, Identifiable {
    case createWithAsset(Asset)
}

final class SearchAssetsForTransactionScreenRouter: DefaultRootRouter<SearchAssetsForTransactionScreenRoute> { }

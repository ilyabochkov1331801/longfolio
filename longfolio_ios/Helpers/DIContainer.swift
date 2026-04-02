//
//  DIContainer.swift
//  longfolio
//
//  Created by Илья Бочков on 2.04.26.
//

import SharedNetwork
import SwiftData
import Combine

final class DIContainer: ObservableObject {
    let eodhdNetworkService: EodhdNetworkServiceProtocol
    
    init() {
        eodhdNetworkService = EodhdNetworkService()
    }
}

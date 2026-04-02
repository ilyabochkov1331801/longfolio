//
//  LongFolioApp.swift
//  longfolio_ios
//
//  Created by Илья Бочков on 11.03.26.
//

import SwiftUI

@main
struct LongFolioApp: App {
    @State var dependencyContainer = DIContainer()
    
    var body: some Scene {
        WindowGroup {
            RootScreenView(viewModel: RootScreenViewModel(dependencyContainer: dependencyContainer))
                .environmentObject(dependencyContainer)
        }
    }
}

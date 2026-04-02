//
//  LongFolioApp.swift
//  longfolio_ios
//
//  Created by Илья Бочков on 11.03.26.
//

import SwiftUI

@main
struct LongFolioApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: ContentViewModel())
        }
    }
}

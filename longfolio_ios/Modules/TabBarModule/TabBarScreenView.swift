//
//  TabBarScreenView.swift
//  longfolio
//
//  Created by Илья Бочков on 2.04.26.
//

import SwiftUI

struct TabBarScreenView: View {
    @EnvironmentObject private var dependencyContainer: DIContainer
    
    @StateObject var router: TabBarScreenRouter
    @State var viewModel: TabBarScreenViewModel
    
    var body: some View {
        TabView(selection: $router.selectedTab) {
            PortfoliosScreen(
                viewModel: .init(dependencyContainer: dependencyContainer),
                router: .init()
            )
            .tabItem {
                Label("Portfolio", systemImage: "briefcase.fill")
            }
            .tag(Tab.portfolios)
            
            Text("Assets")
                .tabItem {
                    Label("Assets", systemImage: "briefcase.fill")
                }
                .tag(Tab.assets)
            
            Text("Settings")
                .tabItem {
                    Label("Settings", systemImage: "briefcase.fill")
                }
                .tag(Tab.settings)
        }
        .environmentObject(router)
    }
}

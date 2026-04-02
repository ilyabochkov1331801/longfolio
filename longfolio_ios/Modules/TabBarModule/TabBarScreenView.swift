//
//  TabBarScreenView.swift
//  longfolio
//
//  Created by Илья Бочков on 2.04.26.
//

import SwiftUI

struct TabBarScreenView: View {
    @State var viewModel: TabBarScreenViewModel
    @StateObject var tabBarRouter = TabBarScreenRouter()
    
    var body: some View {
        TabView(selection: $tabBarRouter.selectedTab) {
            PortfoliosScrenView(viewModel: viewModel.portfoliosScrenViewModel)
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
        .environmentObject(tabBarRouter)
    }
}

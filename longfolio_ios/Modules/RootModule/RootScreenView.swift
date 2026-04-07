//
//  RootScreenView.swift
//  longfolio
//
//  Created by Илья Бочков on 2.04.26.
//

import SwiftUI

struct RootScreenView: View {
    @EnvironmentObject var dependencyContainer: DIContainer
    
    @State var viewModel: RootScreenViewModel
    
    var body: some View {
        TabBarScreenView(
            router: .init(),
            viewModel: .init(dependencyContainer: dependencyContainer)
        )
    }
}

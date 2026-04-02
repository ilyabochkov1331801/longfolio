//
//  PortfoliosScrenView.swift
//  longfolio
//
//  Created by Илья Бочков on 2.04.26.
//

import SwiftUI
 
struct PortfoliosScrenView: View {
    @StateObject var router = PortfoliosScreenRouter()
    @State var viewModel: PortfoliosScrenViewModel
    
    var body: some View {
        BaseScreenView(
            state: $viewModel.state,
            router: router
        ) { screenModel in
            Text("Screen")
        } navigation: { route in
            switch route {
            case .createNewPortfolio:
                Text("")
            case let .portfolioDetails(portfolio):
                Text("")
            }
        }
        .task {
            await viewModel.loadPortfolios()
        }
    }
}

//
//  ContentView.swift
//  longfolio_ios
//
//  Created by Илья Бочков on 11.03.26.
//

import SwiftUI
import SharedModels
import SharedNetwork

struct ContentView: View {
    @State var viewModel: ContentViewModel
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
        .task {
            await viewModel.loadData()
        }
    }
}

@Observable
final class ContentViewModel {
    private let massiveNetworkService = MassiveNetworkService()
    private let eodhdNetworkService = EodhdNetworkService()
    
    func loadData() async {
        do {
            let assets = try await eodhdNetworkService.searchAssets(for: "4GLD")
            guard let asset = assets.first else { return }
            let prices = try await eodhdNetworkService.assetPrices(
                for: asset.code,
                exchange: asset.exchange,
                fromDate: Date().addingTimeInterval(-3 * 24 * 60 * 60),
                toDate: Date()
            A)
            print(prices)
        } catch {
            print(error.localizedDescription)
        }
    }
}

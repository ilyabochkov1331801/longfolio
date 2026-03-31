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
    private let networkService = NetworkService()
    
    func loadData() async {
        do {
            let ticker = try await networkService.getTickers(tickerQuery: "SMCI")
            print(ticker)
        } catch {
            
        }
    }
}

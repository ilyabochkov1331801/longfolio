//
//  ConvertedAmountViewModel.swift
//  longfolio
//
//  Created by Alena Nesterkina on 23.04.2026.
//

import SharedWorkers
import SharedModels
import Combine
import Observation
import Foundation

@Observable
public final class ConvertedAmountViewModel {
    private let converter: ConvertsCurrency
    private let settingsProvider: ProvidesSettings
    private var convertedDate: Date
    private var cancelBag: Set<AnyCancellable> = []
    
    var convertedAmount: Amount?
    var convertedProfit: Amount?
    var amount: [Amount]
    var profitAmount: [Amount]
    
    init(diContatiner: DIContainer, amount: [Amount], profitAmount: [Amount] = [], convertedDate: Date) {
        self.converter = diContatiner.converter
        settingsProvider = diContatiner.settingsProvider
        self.amount = amount
        self.profitAmount = profitAmount
        self.convertedDate = convertedDate
    }
    
    func setupData() async {
        self.convertedAmount = await convertAmount(amount: amount)
        self.convertedProfit = await convertAmount(amount: profitAmount)
    }
    
    private func setupBindings() {
        settingsProvider.updatesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notification in
                guard let self = self else {
                    return
                }
                
                Task {
                    self.convertedAmount = await self.convertAmount(amount: self.amount)
                    self.convertedProfit = await self.convertAmount(amount: self.profitAmount)
                }
            }
            .store(in: &cancelBag)
    }
    
    private func convertAmount(amount: [Amount]) async -> Amount? {
        do {
            let defaultCurrency = try settingsProvider.getDefaultCurrency()
            return try await converter.convert(to: defaultCurrency, amount: amount, date: convertedDate)
        } catch {
            print(error)
            return nil
        }
    }
}

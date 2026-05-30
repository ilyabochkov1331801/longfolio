//
//  PortfolioDetailsScreenView.swift
//  longfolio
//
//  Created by Assistant on 06.04.26.
//

import SwiftUI
import SharedModels

struct PortfolioDetailsScreenView: View {
    @EnvironmentObject private var dependencyContainer: DIContainer

    @State var viewModel: PortfolioDetailsScreenViewModel
    @StateObject var router: PortfolioDetailsScreenRouter

    var body: some View {
        BaseScreenView(router: router) {
            screenContent
        } navigation: { route in
            switch route {
            case let .transactions(portfolio):
                TransactionsScreenView(
                    viewModel: .init(dependencyContainer: dependencyContainer, portfolio: portfolio),
                    router: .init(root: router.root, parent: router)
                )
            case let .createCashTransaction(portfolio):
                CreateCashTransactionScreenView(
                    viewModel: .init(dependencyContainer: dependencyContainer, portfolio: portfolio),
                    router: .init(parent: router)
                )
            case let .createAssetTransaction(portfolio):
                SearchAssetsForTransactionScreenView(
                    viewModel: .init(dependencyContainer: dependencyContainer, portfolio: portfolio),
                    router: .init(parent: router)
                )
            case let .createDividendTransaction(portfolio):
                CreateDividendTransactionScreenView(
                    viewModel: .init(dependencyContainer: dependencyContainer, portfolio: portfolio),
                    router: .init(parent: router)
                )
            case let .openHistory(portfolio):
                PortfolioHistoryScreenView(
                    viewModel: .init(dependencyContainer: dependencyContainer, portfolio: portfolio),
                    router: .init(parent: router)
                )
            }
        }
        .task {
            await viewModel.loadPortfolio()
        }
    }

    @ViewBuilder
    private var screenContent: some View {
        List {
            PortfolioDetailsHeaderView(
                portfolioAmount: viewModel.totalAmount,
                profitAmount: viewModel.profitAmount,
                dependencyContainer: dependencyContainer
            )

            Section("Cash Balance") {
                if viewModel.portfolio.cashAmount.isEmpty {
                    Text("No cash balance yet")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(viewModel.portfolio.cashAmount.sorted(), id: \.currency) { amount in
                        HStack {
                            Text(amount.currency.rawValue.uppercased())
                                .font(.headline)

                            Spacer()

                            AmountView(amount: amount)
                        }
                    }
                }
            }

            Section("Positions") {
                if viewModel.positionsForDisplaying.isEmpty {
                    Text("No positions yet")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(viewModel.positionsForDisplaying, id: \.asset) { position in
                        PositionPreviewView(
                            position: position,
                            amount: viewModel.positionsAmount[position.asset],
                            profit: viewModel.positionsProfit[position.asset]
                        )
                    }
                }
                
                if viewModel.canShowMorePositions {
                    Button("All positions") {
                        
                    }
                }
            }

            Section("Transactions") {
                Button {
                    router.navigate(to: .transactions(viewModel.portfolio))
                } label: {
                    HStack {
                        Text("Open Transactions")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.footnote)
                            .foregroundStyle(.tertiary)
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(viewModel.portfolio.name)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button {
                    router.navigateModaly(to: .openHistory(viewModel.portfolio))
                } label: {
                    Image(systemName: "clock.arrow.circlepath")
                }

                Menu {
                    Button("Cash") {
                        router.navigateModaly(to: .createCashTransaction(viewModel.portfolio))
                    }

                    Button("Asset") {
                        router.navigateModaly(to: .createAssetTransaction(viewModel.portfolio))
                    }

                    Button("Dividends") {
                        router.navigateModaly(to: .createDividendTransaction(viewModel.portfolio))
                    }
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }
}

private struct PortfolioDetailsHeaderView: View {
    let portfolioAmount: [Amount]?
    let profitAmount: [Amount]?
    let dependencyContainer: DIContainer

    var body: some View {
        if let portfolioAmount, let profitAmount {
            PortfolioDetailsStatisticsView(
                dependencyContainer: dependencyContainer,
                amount: portfolioAmount,
                profitAmount: profitAmount
            )
        } else {
            PortfolioDetailsHeaderSkeletonView()
        }
    }
}

private struct PortfolioDetailsStatisticsView: View {
    @State private var viewModel: ConvertedAmountViewModel

    private let dependencyContainer: DIContainer
    private let amount: [Amount]
    private let profitAmount: [Amount]
    private let convertedDate: Date

    init(dependencyContainer: DIContainer, amount: [Amount], profitAmount: [Amount]) {
        self.dependencyContainer = dependencyContainer
        self.amount = amount
        self.profitAmount = profitAmount
        self.convertedDate = Date()
        _viewModel = State(initialValue: .init(
            diContatiner: dependencyContainer,
            amount: amount,
            profitAmount: profitAmount,
            convertedDate: Date()
        ))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text("Portfolio Value")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Spacer(minLength: 12)

                Text("Profit")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            HStack(alignment: .center, spacing: 14) {
                ConvertedAmountView(
                    viewModel: .init(
                        diContatiner: dependencyContainer,
                        amount: amount,
                        profitAmount: profitAmount,
                        convertedDate: convertedDate
                    ),
                    displayMode: .amountOnly
                )
                .font(.largeTitle.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .layoutPriority(1)

                Spacer(minLength: 8)

                VStack(alignment: .trailing, spacing: 4) {
                    profitView
                    profitPercentView
                }
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .frame(minWidth: 116, alignment: .trailing)
            }
        }
        .padding(.vertical, 8)
        .task {
            await updateStatistics()
        }
        .onChange(of: amount) {
            Task {
                await updateStatistics()
            }
        }
        .onChange(of: profitAmount) {
            Task {
                await updateStatistics()
            }
        }
    }

    @ViewBuilder
    private var profitPercentView: some View {
        OptionalValueView(
            formattedProfitPercent,
            placeholderSize: CGSize(width: 76, height: percentHeight)
        ) { formattedProfitPercent in
            Text(formattedProfitPercent)
                .font(.title3.weight(.semibold))
                .foregroundStyle(profitColor)
        }
    }

    @ViewBuilder
    private var profitView: some View {
        OptionalValueView(
            convertedProfit,
            placeholderSize: CGSize(width: 120, height: profitHeight)
        ) { profit in
            ProfitAmountView(profit: profit)
                .font(.title3.weight(.semibold))
        }
    }

    private func updateStatistics() async {
        viewModel.update(amount: amount, profitAmount: profitAmount, convertedDate: convertedDate)
        await viewModel.setupData()
    }

    private var convertedProfit: Amount? {
        viewModel.convertedProfit
    }

    private var formattedProfitPercent: String? {
        guard let profitPercent else {
            return nil
        }

        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: profitPercent))
    }

    private var profitPercent: Double? {
        guard
            let amount = viewModel.convertedAmount,
            let profit = viewModel.convertedProfit
        else {
            return nil
        }

        let investedAmount = amount.value - profit.value
        guard investedAmount != 0 else {
            return nil
        }

        return profit.value / abs(investedAmount)
    }

    private var profitColor: Color {
        guard let profit = viewModel.convertedProfit else {
            return .secondary
        }

        if profit.value > 0 {
            return .green
        } else if profit.value < 0 {
            return .red
        } else {
            return .secondary
        }
    }

    private var profitHeight: CGFloat {
        UIFont.preferredFont(forTextStyle: .title3).lineHeight
    }

    private var percentHeight: CGFloat {
        UIFont.preferredFont(forTextStyle: .title3).lineHeight
    }
}

private struct PortfolioDetailsHeaderSkeletonView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text("Portfolio Value")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Spacer(minLength: 12)

                Text("Profit")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            HStack(alignment: .center, spacing: 14) {
                HStack(spacing: 8) {
                    ShimmerPlaceholderView(size: CGSize(width: 180, height: titleHeight))
                    ShimmerPlaceholderView(size: CGSize(width: 24, height: 24))
                }
                .layoutPriority(1)

                Spacer(minLength: 8)

                VStack(alignment: .trailing, spacing: 4) {
                    ShimmerPlaceholderView(size: CGSize(width: 120, height: percentHeight))
                    ShimmerPlaceholderView(size: CGSize(width: 76, height: percentHeight))
                }
                .frame(minWidth: 116, alignment: .trailing)
            }
        }
        .padding(.vertical, 8)
    }

    private var titleHeight: CGFloat {
        UIFont.preferredFont(forTextStyle: .largeTitle).lineHeight
    }

    private var percentHeight: CGFloat {
        UIFont.preferredFont(forTextStyle: .title3).lineHeight
    }

}

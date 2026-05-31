//
//  PortfoliosScrenView.swift
//  longfolio
//
//  Created by Илья Бочков on 2.04.26.
//

import SwiftUI
import SharedModels

struct PortfoliosScreenView: View {
    @EnvironmentObject private var dependencyContainer: DIContainer

    @State var viewModel: PortfoliosScreenViewModel
    @StateObject var router: PortfoliosScreenRouter

    var body: some View {
        RootScreenView(router: router) {
            screenContent
                .navigationTitle("Portfolios")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            router.navigateModaly(to: .createNewPortfolio)
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
        } navigation: { route in
            switch route {
            case .createNewPortfolio:
                CreateNewPortfolioScreenView(
                    viewModel: .init(dependencyContainer: dependencyContainer),
                    router: .init(parent: router)
                )
            case let .portfolioDetails(portfolio, mode):
                PortfolioDetailsScreenView(
                    viewModel: .init(
                        dependencyContainer: dependencyContainer,
                        portfolio: portfolio,
                        mode: mode
                    ),
                    router: .init(root: router, parent: router)
                )
            }
        }
        .task {
            viewModel.loadPortfolios()
        }
    }

    @ViewBuilder
    private var screenContent: some View {
        List {
            ForEach(viewModel.portfolios, id: \.name) { portfolio in
                Button {
                    router.navigate(to: .portfolioDetails(portfolio, .single))
                } label: {
                    PortfolioSummaryCell(
                        portfolio: portfolio,
                        portfolioAmount: viewModel.amounts[portfolio.name],
                        profitAmount: viewModel.profits[portfolio.name],
                        dependencyContainer: dependencyContainer
                    )
                }
                .buttonStyle(.plain)
            }
            .onDelete { indeces in
                for index in indeces {
                    viewModel.deletePortfolio(with: viewModel.portfolios[index].name)
                }
            }
                        
            Section("All portfolios") {
                if let allPortfolios = viewModel.allPortfolios {
                    Button {
                        router.navigate(to: .portfolioDetails(allPortfolios, .allPortfolios))
                    } label: {
                        PortfolioSummaryCell(
                            title: "Total",
                            portfolioAmount: viewModel.totalAmount,
                            profitAmount: viewModel.totalProfit,
                            dependencyContainer: dependencyContainer
                        )
                    }
                    .buttonStyle(.plain)
                } else {
                    PortfolioSummaryCell(
                        title: "Total",
                        portfolioAmount: viewModel.totalAmount,
                        profitAmount: viewModel.totalProfit,
                        dependencyContainer: dependencyContainer
                    )
                }
            }
            
        }
        .listStyle(.insetGrouped)
        .overlay {
            if viewModel.portfolios.isEmpty {
                ContentUnavailableView(
                    "No portfolios yet",
                    systemImage: "briefcase",
                    description: Text("Create or import a portfolio to start tracking assets.")
                )
            }
        }
    }
}

private struct PortfolioSummaryCell: View {
    let title: String
    let portfolioAmount: [Amount]?
    let profitAmount: [Amount]?
    let dependencyContainer: DIContainer

    init(
        portfolio: Portfolio,
        portfolioAmount: [Amount]?,
        profitAmount: [Amount]?,
        dependencyContainer: DIContainer
    ) {
        self.title = portfolio.name
        self.portfolioAmount = portfolioAmount
        self.profitAmount = profitAmount
        self.dependencyContainer = dependencyContainer
    }

    init(
        title: String,
        portfolioAmount: [Amount]?,
        profitAmount: [Amount]?,
        dependencyContainer: DIContainer
    ) {
        self.title = title
        self.portfolioAmount = portfolioAmount
        self.profitAmount = profitAmount
        self.dependencyContainer = dependencyContainer
    }

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.leading)

            Spacer(minLength: 12)

            if let portfolioAmount, let profitAmount {
                PortfolioStatisticsView(viewModel: .init(
                    diContatiner: dependencyContainer,
                    amount: portfolioAmount,
                    profitAmount: profitAmount,
                    convertedDate: Date()
                ))
            } else {
                PortfolioStatisticsSkeletonView()
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
}

private struct PortfolioStatisticsSkeletonView: View {
    var body: some View {
        VStack(alignment: .trailing, spacing: 6) {
            StatisticSkeletonRow()
            StatisticSkeletonRow(width: 124)
            StatisticSkeletonRow(width: 110)
        }
        .font(.subheadline)
    }
}

private struct StatisticSkeletonRow: View {
    let width: CGFloat

    init(width: CGFloat = 142) {
        self.width = width
    }

    var body: some View {
        Text("Amount")
            .font(.subheadline)
            .hidden()
            .overlay(alignment: .trailing) {
                OptionalValueView(
                    Optional<String>.none,
                    placeholderSize: CGSize(width: width, height: textHeight)
                ) { value in
                    Text(value)
                }
            }
    }

    private var textHeight: CGFloat {
        UIFont.preferredFont(forTextStyle: .subheadline).lineHeight
    }
}

private struct PortfolioStatisticsView: View {
    @State private var viewModel: ConvertedAmountViewModel

    private let amount: [Amount]
    private let profitAmount: [Amount]
    private let convertedDate: Date

    init(viewModel: ConvertedAmountViewModel) {
        self.amount = viewModel.amount
        self.profitAmount = viewModel.profitAmount
        self.convertedDate = Date()
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        Grid(alignment: .trailing, horizontalSpacing: 12, verticalSpacing: 6) {
            statisticRow(
                title: "Amount",
                value: viewModel.convertedAmount,
                placeholderWidth: 142
            ) { amount in
                AmountView(amount: amount)
            }

            statisticRow(
                title: "Profit",
                value: viewModel.convertedProfit,
                placeholderWidth: 124
            ) { profit in
                ProfitAmountView(profit: profit)
            }

            statisticRow(
                title: "Return",
                value: formattedProfitPercent,
                placeholderWidth: 110
            ) { formattedProfitPercent in
                Text(formattedProfitPercent)
                    .foregroundStyle(profitColor)
            }
        }
        .font(.subheadline)
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
    private func statisticRow<Value, Content: View>(
        title: String,
        value: Value?,
        placeholderWidth: CGFloat,
        @ViewBuilder content: @escaping (Value) -> Content
    ) -> some View {
        OptionalValueView(value) { value in
            GridRow(alignment: .firstTextBaseline) {
                Text(title)
                    .foregroundStyle(.secondary)
                    .gridColumnAlignment(.leading)

                content(value)
                    .multilineTextAlignment(.trailing)
                    .gridColumnAlignment(.trailing)
            }
        } placeholder: {
            StatisticSkeletonRow(width: placeholderWidth)
        }
    }

    private func updateStatistics() async {
        viewModel.update(amount: amount, profitAmount: profitAmount, convertedDate: convertedDate)
        await viewModel.setupData()
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
}

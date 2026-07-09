//
//  TransactionsScreenView.swift
//  longfolio
//
//  Created by Assistant on 08.04.26.
//

import SwiftUI
import SharedModels
import SharedNetwork
import SharedWorkers

struct TransactionsScreenView: View {
    @State var viewModel: TransactionsScreenViewModel
    @StateObject var router: TransactionsScreenRouter
    @State private var transactionEditor: TransactionEditor?
    @State private var transactionCancellation: TransactionCancellation?

    var body: some View {
        BaseScreenView(router: router) {
            screenContent
        }
        .task {
            viewModel.loadTransactions()
        }
        .sheet(item: $transactionEditor) { editor in
            TransactionEditorView(editor: editor, portfolio: viewModel.portfolio) { editedTransaction in
                updateTransaction(editedTransaction)
            }
        }
        .alert(
            "Cancel Transaction?",
            isPresented: Binding(
                get: { transactionCancellation != nil },
                set: { isPresented in if !isPresented { transactionCancellation = nil } }
            ),
            presenting: transactionCancellation,
            actions: { cancellation in
                Button("Keep", role: .cancel) {
                    transactionCancellation = nil
                }
                Button("Cancel Transaction", role: .destructive) {
                    if cancelTransaction(cancellation) {
                        transactionCancellation = nil
                    }
                }
            },
            message: { cancellation in
                Text("This will remove \(cancellation.title) and recalculate the portfolio.")
            }
        )
        .alert(
            "Something went wrong",
            isPresented: Binding(
                get: { viewModel.error != nil },
                set: { isPresented in if !isPresented { viewModel.error = nil } }
            ),
            actions: {
                Button("OK", role: .cancel) { viewModel.error = nil }
            },
            message: {
                Text(viewModel.error ?? "")
            }
        )
    }

    @ViewBuilder
    private var screenContent: some View {
        List {
            cashTransactionsSection
            assetTransactionsSection
            dividendTransactionsSection
        }
        .listStyle(.plain)
        .navigationTitle("Transactions")
    }

    @ViewBuilder
    private var cashTransactionsSection: some View {
        Section("Cash Transactions") {
            if viewModel.portfolio.cashTransactions.isEmpty {
                Text("No cash transactions yet")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(viewModel.portfolio.cashTransactions, id: \.id) { transaction in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(transaction.amount.currency.rawValue.uppercased())
                                .font(.headline)
                            Text(transaction.date, style: .date)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Text(transaction.amount.value, format: .number.precision(.fractionLength(2)))
                            .font(.body.weight(.medium))
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        cancelButton(for: .cash(transaction))
                        editButton(for: .cash(transaction))
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var assetTransactionsSection: some View {
        Section("Asset Transactions") {
            if viewModel.portfolio.assetsTransactions.isEmpty {
                Text("No asset transactions yet")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(viewModel.portfolio.assetsTransactions, id: \.id) { transaction in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(assetTransactionTitle(transaction))
                                    .font(.headline)
                                Text(assetTransactionSubtitle(transaction))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            VStack(alignment: .trailing, spacing: 4) {
                                AmountView(amount: transaction.amount)
                                if let profit = transaction.type.realizedProfit {
                                    ProfitAmountView(profit: profit)
                                }
                            }
                        }

                        if transaction.type.isSell {
                            Text(sellDetails(for: transaction))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        } else if transaction.commision.value > 0 {
                            Text(commissionDetails(for: transaction))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        cancelButton(for: .asset(transaction))
                        editButton(for: .asset(transaction))
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var dividendTransactionsSection: some View {
        Section("Dividend Transactions") {
            if viewModel.portfolio.dividendsTransactions.isEmpty {
                Text("No dividend transactions yet")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(viewModel.portfolio.dividendsTransactions, id: \.id) { transaction in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(transaction.asset.ticker.ticker)
                                .font(.headline)
                            Text(transaction.date, style: .date)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Text(transaction.amount.value, format: .number.precision(.fractionLength(2)))
                            .font(.body.weight(.medium))
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        cancelButton(for: .dividend(transaction))
                        editButton(for: .dividend(transaction))
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func editButton(for editor: TransactionEditor) -> some View {
        if viewModel.canEditTransactions {
            Button {
                transactionEditor = editor
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            .tint(.blue)
        }
    }

    @ViewBuilder
    private func cancelButton(for cancellation: TransactionCancellation) -> some View {
        if viewModel.canEditTransactions {
            Button(role: .destructive) {
                transactionCancellation = cancellation
            } label: {
                Label("Cancel", systemImage: "xmark.circle")
            }
        }
    }

    private func updateTransaction(_ editor: TransactionEditor) -> Bool {
        switch editor.kind {
        case .cash:
            return viewModel.updateCashTransaction(
                id: editor.transactionID,
                amount: Amount(value: editor.amount, currency: editor.currency),
                date: editor.date
            )
        case let .asset(isSell):
            guard let asset = editor.asset else { return false }
            let amount = Amount(value: editor.amount, currency: editor.currency)
            let commision = Amount(value: editor.commission, currency: editor.currency)
            if isSell {
                return viewModel.updateSellAssetTransaction(
                    id: editor.transactionID,
                    asset: asset,
                    quantity: editor.quantity,
                    amount: amount,
                    commision: commision,
                    date: editor.date
                )
            }
            return viewModel.updateBuyAssetTransaction(
                id: editor.transactionID,
                asset: asset,
                quantity: editor.quantity,
                amount: amount,
                commision: commision,
                date: editor.date
            )
        case .dividend:
            guard let asset = editor.asset else { return false }
            return viewModel.updateDividendTransaction(
                id: editor.transactionID,
                asset: asset,
                amount: Amount(value: editor.amount, currency: editor.currency),
                paidTaxes: Amount(value: editor.paidTaxes, currency: editor.currency),
                date: editor.date
            )
        }
    }

    private func cancelTransaction(_ cancellation: TransactionCancellation) -> Bool {
        switch cancellation.kind {
        case .cash:
            return viewModel.deleteCashTransaction(id: cancellation.transactionID)
        case let .asset(isSell):
            return viewModel.deleteAssetTransaction(id: cancellation.transactionID, isSell: isSell)
        case .dividend:
            return viewModel.deleteDividendTransaction(id: cancellation.transactionID)
        }
    }

    private func assetTransactionTitle(_ transaction: AssetTransaction) -> String {
        "\(transaction.type.isSell ? "Sell" : "Buy") \(transaction.asset.ticker.ticker)"
    }

    private func assetTransactionSubtitle(_ transaction: AssetTransaction) -> String {
        let quantity = transaction.quantity.formatted(.number)
        return "\(quantity) units • \(transaction.date.formatted(date: .abbreviated, time: .omitted))"
    }

    private func sellDetails(for transaction: AssetTransaction) -> String {
        let closedLots = transaction.type.closedLots.count
        if transaction.commision.value > 0 {
            return "Closed \(closedLots) lot\(closedLots == 1 ? "" : "s") • Commission \(transaction.commision.formatted ?? "NaN")"
        }
        return "Closed \(closedLots) lot\(closedLots == 1 ? "" : "s")"
    }

    private func commissionDetails(for transaction: AssetTransaction) -> String {
        "Commission \(transaction.commision.formatted ?? "NaN")"
    }
}

private struct TransactionCancellation: Identifiable {
    let transactionID: String
    let title: String
    let kind: TransactionEditor.Kind

    var id: String {
        "\(kind.idPrefix)-\(transactionID)"
    }

    static func cash(_ transaction: CashTransaction) -> TransactionCancellation {
        TransactionCancellation(
            transactionID: transaction.id,
            title: "cash transaction",
            kind: .cash
        )
    }

    static func asset(_ transaction: AssetTransaction) -> TransactionCancellation {
        TransactionCancellation(
            transactionID: transaction.id,
            title: "\(transaction.type.isSell ? "sell" : "buy") \(transaction.asset.ticker.ticker)",
            kind: .asset(isSell: transaction.type.isSell)
        )
    }

    static func dividend(_ transaction: DividendTransaction) -> TransactionCancellation {
        TransactionCancellation(
            transactionID: transaction.id,
            title: "dividend from \(transaction.asset.ticker.ticker)",
            kind: .dividend
        )
    }
}

private struct TransactionEditor: Identifiable {
    enum Kind {
        case cash
        case asset(isSell: Bool)
        case dividend

        var idPrefix: String {
            switch self {
            case .cash:
                "cash"
            case .asset:
                "asset"
            case .dividend:
                "dividend"
            }
        }

        var hasAsset: Bool {
            switch self {
            case .cash:
                false
            case .asset, .dividend:
                true
            }
        }
    }

    let transactionID: String
    let title: String
    let kind: Kind
    var asset: Asset?
    var currency: Currency
    var date: Date
    var amount: Double
    var quantity: Double
    var commission: Double
    var paidTaxes: Double

    var id: String {
        "\(kind.idPrefix)-\(transactionID)"
    }

    var canSave: Bool {
        switch kind {
        case .cash:
            amount != 0
        case .asset:
            asset != nil && amount > 0 && quantity > 0
        case .dividend:
            asset != nil && amount > 0 && paidTaxes >= 0
        }
    }

    static func cash(_ transaction: CashTransaction) -> TransactionEditor {
        TransactionEditor(
            transactionID: transaction.id,
            title: "Edit Cash Transaction",
            kind: .cash,
            asset: nil,
            currency: transaction.amount.currency,
            date: transaction.date,
            amount: transaction.amount.value,
            quantity: 0,
            commission: 0,
            paidTaxes: 0
        )
    }

    static func asset(_ transaction: AssetTransaction) -> TransactionEditor {
        TransactionEditor(
            transactionID: transaction.id,
            title: "Edit \(transaction.type.isSell ? "Sell" : "Buy") \(transaction.asset.ticker.ticker)",
            kind: .asset(isSell: transaction.type.isSell),
            asset: transaction.asset,
            currency: transaction.amount.currency,
            date: transaction.date,
            amount: transaction.amount.value,
            quantity: transaction.quantity,
            commission: transaction.commision.value,
            paidTaxes: 0
        )
    }

    static func dividend(_ transaction: DividendTransaction) -> TransactionEditor {
        TransactionEditor(
            transactionID: transaction.id,
            title: "Edit Dividend",
            kind: .dividend,
            asset: transaction.asset,
            currency: transaction.amount.currency,
            date: transaction.date,
            amount: transaction.amount.value,
            quantity: 0,
            commission: 0,
            paidTaxes: transaction.paidTaxes.value
        )
    }
}

private struct TransactionEditorView: View {
    @EnvironmentObject private var dependencyContainer: DIContainer
    @Environment(\.dismiss) private var dismiss
    @State private var editor: TransactionEditor
    @State private var isSelectingAsset = false

    let portfolio: Portfolio
    let onSave: (TransactionEditor) -> Bool

    init(editor: TransactionEditor, portfolio: Portfolio, onSave: @escaping (TransactionEditor) -> Bool) {
        self._editor = State(initialValue: editor)
        self.portfolio = portfolio
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                if editor.kind.hasAsset {
                    Section("Asset") {
                        Button {
                            isSelectingAsset = true
                        } label: {
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(editor.asset?.ticker.ticker ?? "Select Asset")
                                        .font(.headline)
                                    if let asset = editor.asset {
                                        Text(asset.ticker.exchange.code)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }

                                Spacer()

                                Text("Change")
                                    .font(.subheadline.weight(.medium))
                                Image(systemName: "chevron.right")
                                    .font(.footnote)
                                    .foregroundStyle(.tertiary)
                            }
                            .padding(.vertical, 4)
                        }
                        .buttonStyle(.plain)
                    }
                }

                Section("Transaction") {
                    DatePicker(
                        "Date",
                        selection: $editor.date,
                        displayedComponents: .date
                    )

                    if case .cash = editor.kind {
                        CurrencySelector(selection: $editor.currency)
                    }

                    TextInput(
                        output: $editor.amount,
                        configuration: .init(
                            title: "Amount",
                            placeholder: "Enter amount",
                            hint: amountHint,
                            keyboardType: .decimalPad,
                            formatter: AmountTextInputFormatter()
                        ),
                        initialText: editor.amount.inputText
                    )

                    if case .asset = editor.kind {
                        TextInput(
                            output: $editor.quantity,
                            configuration: .init(
                                title: "Quantity",
                                placeholder: "Enter quantity",
                                hint: "Number of shares or units",
                                keyboardType: .decimalPad,
                                formatter: AmountTextInputFormatter()
                            ),
                            initialText: editor.quantity.inputText
                        )

                        TextInput(
                            output: $editor.commission,
                            configuration: .init(
                                title: "Commission",
                                placeholder: "Enter commission",
                                hint: "Broker fee",
                                keyboardType: .decimalPad,
                                formatter: AmountTextInputFormatter()
                            ),
                            initialText: editor.commission.inputText
                        )
                    }

                    if case .dividend = editor.kind {
                        TextInput(
                            output: $editor.paidTaxes,
                            configuration: .init(
                                title: "Paid Taxes",
                                placeholder: "Enter paid taxes",
                                hint: "Taxes withheld from dividend",
                                keyboardType: .decimalPad,
                                formatter: AmountTextInputFormatter()
                            ),
                            initialText: editor.paidTaxes.inputText
                        )
                    }
                }
            }
            .navigationTitle(editor.title)
            .sheet(isPresented: $isSelectingAsset) {
                TransactionAssetPickerView(
                    viewModel: .init(
                        dependencyContainer: dependencyContainer,
                        portfolio: portfolio,
                        selectedAsset: editor.asset
                    ),
                    selectedAsset: editor.asset
                ) { asset in
                    editor.asset = asset
                    editor.currency = asset.currency
                    isSelectingAsset = false
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if onSave(editor) {
                            dismiss()
                        }
                    }
                    .disabled(!editor.canSave)
                }
            }
        }
    }

    private var amountHint: String {
        switch editor.kind {
        case .cash:
            "Use a positive or negative value"
        case let .asset(isSell):
            isSell ? "Total sale amount" : "Total transaction amount"
        case .dividend:
            "Dividend amount received"
        }
    }
}

private struct TransactionAssetPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @State var viewModel: TransactionAssetPickerViewModel

    let selectedAsset: Asset?
    let onSelect: (Asset) -> Void

    var body: some View {
        NavigationStack {
            List {
                if viewModel.displayedAssets.isEmpty {
                    ContentUnavailableView(
                        "No assets found",
                        systemImage: "magnifyingglass",
                        description: Text(viewModel.emptyStateDescription())
                    )
                    .listRowSeparator(.hidden)
                } else {
                    ForEach(viewModel.displayedAssets, id: \.self) { asset in
                        Button {
                            onSelect(asset)
                            dismiss()
                        } label: {
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(asset.ticker.ticker)
                                        .font(.headline)
                                    Text(asset.ticker.exchange.code)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                if asset == selectedAsset {
                                    Image(systemName: "checkmark")
                                        .font(.body.weight(.semibold))
                                        .foregroundStyle(.tint)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .listStyle(.plain)
            .searchable(
                text: $viewModel.tickerQuery,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Search asset or exchange"
            )
            .navigationTitle("Select Asset")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .alert(
                "Something went wrong",
                isPresented: Binding(
                    get: { viewModel.error != nil },
                    set: { isPresented in if !isPresented { viewModel.error = nil } }
                ),
                actions: {
                    Button("OK", role: .cancel) { viewModel.error = nil }
                },
                message: {
                    Text(viewModel.error ?? "")
                }
            )
        }
    }
}

@Observable
private final class TransactionAssetPickerViewModel {
    var tickerQuery: String = "" {
        didSet {
            guard oldValue != tickerQuery else { return }
            searchTask?.cancel()
            searchTask = Task {
                try? await Task.sleep(for: .milliseconds(350))
                guard !Task.isCancelled else { return }
                await self.searchAssets(for: tickerQuery)
            }
        }
    }

    var displayedAssets: [Asset]
    var error: String?

    private let portfolio: Portfolio
    private let eodhdNetworkService: EodhdNetworkServiceProtocol
    private let assetsDataManager: ManagesAssetsData
    private let selectedAsset: Asset?
    private var searchTask: Task<Void, Never>?

    init(dependencyContainer: DIContainer, portfolio: Portfolio, selectedAsset: Asset?) {
        let dataBase = SwiftDataBase(contextManager: dependencyContainer.contextManager)
        self.portfolio = portfolio
        self.selectedAsset = selectedAsset
        self.eodhdNetworkService = dependencyContainer.eodhdNetworkService
        self.assetsDataManager = AssetsDataManager(dataBase: dataBase)
        self.displayedAssets = Self.assetsForDisplaying(
            portfolio: portfolio,
            selectedAsset: selectedAsset,
            assetsDataManager: assetsDataManager
        )
    }
}

@MainActor
private extension TransactionAssetPickerViewModel {
    var isSearching: Bool {
        !tickerQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func emptyStateDescription() -> String {
        if isSearching {
            return "Try another ticker or exchange."
        }

        return "Assets from the portfolio will appear here."
    }

    private func searchAssets(for query: String) async {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedQuery.isEmpty else {
            displayedAssets = Self.assetsForDisplaying(
                portfolio: portfolio,
                selectedAsset: selectedAsset,
                assetsDataManager: assetsDataManager
            )
            error = nil
            return
        }

        do {
            let assets = try await eodhdNetworkService.searchAssets(for: trimmedQuery)
            let displayedAssets = assets.map(makeAsset)

            guard !Task.isCancelled, trimmedQuery == tickerQuery.trimmingCharacters(in: .whitespacesAndNewlines) else {
                return
            }

            error = nil
            self.displayedAssets = displayedAssets
        } catch {
            guard !Task.isCancelled else { return }
            self.error = error.localizedDescription
        }
    }

    private static func assetsForDisplaying(
        portfolio: Portfolio,
        selectedAsset: Asset?,
        assetsDataManager: ManagesAssetsData
    ) -> [Asset] {
        var assets = portfolio.positions.compactMap { try? assetsDataManager.fetchAsset(for: $0.asset.ticker) }

        if let selectedAsset, !assets.contains(selectedAsset) {
            assets.insert(selectedAsset, at: 0)
        }

        return assets
    }

    private func makeAsset(from asset: EodhdAsset) -> Asset {
        let currency = Currency(rawValue: asset.currency.lowercased()) ?? .usd
        return Asset(
            ticker: AssetTicker(
                ticker: asset.code,
                exchange: Exchange(
                    name: asset.exchange,
                    code: asset.exchange,
                    country: asset.country,
                    currency: currency
                )
            ),
            currency: currency,
            priceHistory: [
                AssetDayPrice(
                    date: asset.previousCloseDate,
                    price: Amount(value: asset.previousClose, currency: currency)
                )
            ]
        )
    }
}

private extension Double {
    var inputText: String {
        formatted(.number.grouping(.never))
    }
}

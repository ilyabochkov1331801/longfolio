import SwiftUI
import SharedModels

public struct CurrencySelector: View {
    @Binding var selection: Currency

    public init(selection: Binding<Currency>) {
        self._selection = selection
    }

    public var body: some View {
        Picker(
            "Currency",
            selection: $selection
        ) {
            Text("USD").tag(Currency.usd)
            Text("EUR").tag(Currency.eur)
        }
    }
}

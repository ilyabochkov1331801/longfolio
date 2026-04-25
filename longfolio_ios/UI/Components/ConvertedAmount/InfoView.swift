import SwiftUI

public struct InfoView<PopoverContent: View>: View {
    @State private var isPresented: Bool = false
    private let popoverContent: () -> PopoverContent

    public init(@ViewBuilder popoverContent: @escaping () -> PopoverContent) {
        self.popoverContent = popoverContent
    }

    public var body: some View {
        Button {
            isPresented = true
        } label: {
            Image(systemName: "info.circle")
                .symbolRenderingMode(.hierarchical)
                .imageScale(.large)
                .font(.caption)
                .padding(4)
                .background(.ultraThinMaterial, in: Circle())
        }
        .foregroundStyle(Color(.systemGray))
        .buttonStyle(.plain)
        .popover(isPresented: $isPresented, arrowEdge: .top) {
            popoverContent()
                .padding()
                .presentationCompactAdaptation(.popover)
        }
    }
}


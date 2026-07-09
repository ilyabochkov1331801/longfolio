//
//  ShimmerView.swift
//  longfolio
//
//  Created by Codex on 24.05.26.
//

import SwiftUI

struct ShimmerView: View {
    let cornerRadius: CGFloat

    @State private var phase: CGFloat = -1

    init(cornerRadius: CGFloat = 6) {
        self.cornerRadius = cornerRadius
    }

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(.gray.opacity(0.18))
            .overlay {
                GeometryReader { proxy in
                    let width = proxy.size.width

                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    .clear,
                                    .white.opacity(0.42),
                                    .clear
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(width * 0.45, 40))
                        .offset(x: width * phase)
                }
                .clipped()
            }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .onAppear {
                withAnimation(
                    .linear(duration: 1.2)
                    .repeatForever(autoreverses: false)
                ) {
                    phase = 2
                }
            }
            .accessibilityHidden(true)
    }
}

struct ShimmerModifier: ViewModifier {
    let isActive: Bool
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        if isActive {
            content
                .overlay {
                    ShimmerView(cornerRadius: cornerRadius)
                }
        } else {
            content
        }
    }
}

extension View {
    func shimmering(isActive: Bool = true, cornerRadius: CGFloat = 6) -> some View {
        modifier(ShimmerModifier(isActive: isActive, cornerRadius: cornerRadius))
    }
}

struct OptionalValueView<Value, Content: View, Placeholder: View>: View {
    let value: Value?
    private let content: (Value) -> Content
    private let placeholder: () -> Placeholder

    init(
        _ value: Value?,
        @ViewBuilder content: @escaping (Value) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.value = value
        self.content = content
        self.placeholder = placeholder
    }

    var body: some View {
        if let value {
            content(value)
        } else {
            placeholder()
        }
    }
}

struct ShimmerPlaceholderView: View {
    let size: CGSize?

    init(size: CGSize? = nil) {
        self.size = size
    }

    var body: some View {
        ShimmerView()
            .frame(width: size?.width, height: size?.height)
    }
}

extension OptionalValueView where Placeholder == ShimmerPlaceholderView {
    init(
        _ value: Value?,
        placeholderSize: CGSize? = nil,
        @ViewBuilder content: @escaping (Value) -> Content
    ) {
        self.value = value
        self.content = content
        self.placeholder = { ShimmerPlaceholderView(size: placeholderSize) }
    }
}

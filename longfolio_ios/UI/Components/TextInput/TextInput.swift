//
//  TextInput.swift
//  longfolio
//
//  Created by Илья Бочков on 8.04.26.
//

import SwiftUI

struct TextInputConfiguration<Formatter: FormatsTextInput> {
    let title: String
    let placeholder: String
    let hint: String?
    let keyboardType: UIKeyboardType
    let formatter: Formatter

    init(
        title: String,
        placeholder: String,
        hint: String? = nil,
        keyboardType: UIKeyboardType = .default,
        formatter: Formatter
    ) {
        self.title = title
        self.placeholder = placeholder
        self.hint = hint
        self.keyboardType = keyboardType
        self.formatter = formatter
    }
}

struct TextInput<Formatter: FormatsTextInput>: View {
    @Binding private var output: Formatter.Output

    private let configuration: TextInputConfiguration<Formatter>

    @FocusState private var isFocused: Bool
    @State private var validationResult: TextInputValidationResult = .valid
    @State private var hasBeenEdited = false
    @State private var rawText: String

    init(
        output: Binding<Formatter.Output>,
        configuration: TextInputConfiguration<Formatter>,
        initialText: String = ""
    ) {
        self._output = output
        self.configuration = configuration
        self._rawText = State(initialValue: initialText)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !configuration.title.isEmpty {
                Text(configuration.title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.primary)
            }

            TextField(
                configuration.placeholder,
                text: Binding(
                    get: { rawText },
                    set: { updateText(with: $0) }
                )
            )
            .textInputAutocapitalization(.never)
            .keyboardType(configuration.keyboardType)
            .autocorrectionDisabled()
            .focused($isFocused)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(.secondarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(borderColor, lineWidth: 1)
            )
            .onChange(of: isFocused) { _, newValue in
                if !newValue {
                    hasBeenEdited = true
                    validate(rawText)
                }
            }

            if let supportingText {
                Text(supportingText)
                    .font(.footnote)
                    .foregroundStyle(showError ? .red : .secondary)
            }
        }
        .onAppear {
            let formattedValue = configuration.formatter.format(raw: rawText)
            if formattedValue != rawText {
                rawText = formattedValue
            }

            output = configuration.formatter.output(formatted: formattedValue)
            validate(formattedValue)
        }
    }

    private var showError: Bool {
        hasBeenEdited && !validationResult.isValid
    }

    private var borderColor: Color {
        if showError {
            return .red
        }

        if isFocused {
            return .accentColor
        }

        return Color(.separator)
    }

    private var supportingText: String? {
        if showError {
            return validationResult.errorMessage
        }

        return configuration.hint
    }

    private func updateText(with newValue: String) {
        hasBeenEdited = true

        let formattedValue = configuration.formatter.format(raw: newValue)
        rawText = formattedValue

        output = configuration.formatter.output(formatted: formattedValue)
        validate(formattedValue)
    }

    private func validate(_ value: String) {
        let result = configuration.formatter.validate(raw: value)
        validationResult = result
    }
}

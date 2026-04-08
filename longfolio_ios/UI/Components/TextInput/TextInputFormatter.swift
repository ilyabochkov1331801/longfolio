//
//  TextInputFormatter.swift
//  longfolio
//
//  Created by Илья Бочков on 8.04.26.
//

import Foundation

enum TextInputValidationResult: Equatable {
    case valid
    case invalid(String)

    var errorMessage: String? {
        switch self {
        case .valid:
            nil
        case .invalid(let message):
            message
        }
    }

    var isValid: Bool {
        switch self {
        case .valid:
            true
        case .invalid:
            false
        }
    }
}

protocol FormatsTextInput {
    associatedtype Output

    func output(formatted: String) -> Output
    func format(raw: String) -> String
    func validate(raw: String) -> TextInputValidationResult
}

struct PlainTextInputFormatter: FormatsTextInput {
    func output(formatted: String) -> String {
        formatted
    }

    func format(raw: String) -> String {
        raw
    }
    
    func validate(raw: String) -> TextInputValidationResult {
        .valid
    }
}

struct AmountTextInputFormatter: FormatsTextInput {
    func format(raw: String) -> String {
        let allowedCharacters = "0123456789,."
        let filtered = raw.filter { allowedCharacters.contains($0) }

        var didUseDecimalSeparator = false

        return filtered.reduce(into: "") { partialResult, character in
            if character == "." || character == "," {
                guard !didUseDecimalSeparator else { return }
                didUseDecimalSeparator = true
                partialResult.append(".")
            } else {
                partialResult.append(character)
            }
        }
    }

    func output(formatted: String) -> Double {
        Double(formatted) ?? 0
    }

    func validate(raw: String) -> TextInputValidationResult {
        let normalized = format(raw: raw)

        guard !normalized.isEmpty else {
            return .invalid("Enter amount")
        }

        guard let amount = Double(normalized), amount != 0 else {
            return .invalid("Enter a valid amount")
        }

        return .valid
    }
}

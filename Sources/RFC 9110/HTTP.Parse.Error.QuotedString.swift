// HTTP.Parse.Error.QuotedString.swift
// swift-rfc-9110

extension RFC_9110.Parse.Error {
    /// Errors that can occur when parsing an HTTP quoted-string.
    public enum QuotedString: Swift.Error, Sendable, Equatable {
        case expectedOpenQuote
        case unexpectedEndOfInput
        case invalidEscapeSequence
    }
}

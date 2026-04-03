//
//  HTTP.Parse.QuotedString.Error.swift
//  swift-rfc-9110
//
//  Error type for HTTP quoted-string parser.
//

extension HTTP.Parse.QuotedString {
    /// Errors that can occur when parsing an HTTP quoted-string.
    public enum Error: Swift.Error, Sendable, Equatable {
        /// Input does not begin with an opening double-quote.
        case expectedOpenQuote
        /// Input ended before the closing double-quote was found.
        case unexpectedEndOfInput
        /// A backslash was not followed by a valid quoted-pair character.
        case invalidEscapeSequence
    }
}

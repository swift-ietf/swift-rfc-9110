//
//  HTTP.__HTTPQuotedStringParserError.swift
//  swift-rfc-9110
//
//  Module-scope, non-generic error for the HTTP quoted-string parser.
//
//  Hoisted out of the generic `RFC_9110.Parse.QuotedString<Input>` namespace so the
//  `@error` SIL result carries no phantom `Input` type parameter — the structural
//  fix for the `FunctionSignatureOpts` release-build ICE
//  (`SILArgument.cpp:40 !type.hasTypeParameter()`; Research §A13 / swiftlang/swift#89617).
//  Surfaced through the public path `RFC_9110.Parse.QuotedString.Error` (a typealias).
//

/// Errors that can occur when parsing an HTTP quoted-string.
public enum __HTTPQuotedStringParserError: Swift.Error, Sendable, Equatable {
    /// Input does not begin with an opening double-quote.
    case expectedOpenQuote
    /// Input ended before the closing double-quote was found.
    case unexpectedEndOfInput
    /// A backslash was not followed by a valid quoted-pair character.
    case invalidEscapeSequence
}

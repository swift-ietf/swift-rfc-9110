//
//  HTTP.__HTTPTokenParserError.swift
//  swift-rfc-9110
//
//  Module-scope, non-generic error for the HTTP token parser.
//
//  Hoisted out of the generic `RFC_9110.Parse.Token<Input>` namespace so the
//  `@error` SIL result carries no phantom `Input` type parameter — the structural
//  fix for the `FunctionSignatureOpts` release-build ICE
//  (`SILArgument.cpp:40 !type.hasTypeParameter()`; Research §A13 / swiftlang/swift#89617).
//  Surfaced through the public path `RFC_9110.Parse.Token.Error` (a typealias).
//

/// Errors that can occur when parsing an HTTP token.
public enum __HTTPTokenParserError: Swift.Error, Sendable, Equatable {
    /// Input does not begin with a valid token character.
    case expectedToken
}

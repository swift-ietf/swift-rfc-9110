//
//  HTTP.__HTTPParameterParserError.swift
//  swift-rfc-9110
//
//  Module-scope, non-generic error for the HTTP parameter parser.
//
//  Hoisted out of the generic `RFC_9110.Parse.Parameter<Input>` namespace so the
//  `@error` SIL result carries no phantom `Input` type parameter — the structural
//  fix for the `FunctionSignatureOpts` release-build ICE
//  (`SILArgument.cpp:40 !type.hasTypeParameter()`; Research §A13 / swiftlang/swift#89617).
//  Composes the sibling parser's hoisted error directly (no `<Input>`).
//  Surfaced through the public path `RFC_9110.Parse.Parameter.Error` (a typealias).
//

/// Errors that can occur when parsing an HTTP parameter (`name=value`).
public enum __HTTPParameterParserError: Swift.Error, Sendable, Equatable {
    /// The parameter name is not a valid token.
    case expectedToken
    /// Expected an equals sign between the name and value.
    case expectedEquals
    /// No valid token or quoted-string follows the equals sign.
    case expectedValue
    /// The quoted-string value is malformed.
    case invalidQuotedString(__HTTPQuotedStringParserError)
}

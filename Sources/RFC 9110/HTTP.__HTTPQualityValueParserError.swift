//
//  HTTP.__HTTPQualityValueParserError.swift
//  swift-rfc-9110
//
//  Module-scope, non-generic error for the HTTP quality-value parser.
//
//  Hoisted out of the generic `RFC_9110.Parse.QualityValue<Input>` namespace so the
//  `@error` SIL result carries no phantom `Input` type parameter — the structural
//  fix for the `FunctionSignatureOpts` release-build ICE
//  (`SILArgument.cpp:40 !type.hasTypeParameter()`; Research §A13 / swiftlang/swift#89617).
//  Surfaced through the public path `RFC_9110.Parse.QualityValue.Error` (a typealias).
//

/// Errors that can occur when parsing an HTTP quality value.
public enum __HTTPQualityValueParserError: Swift.Error, Sendable, Equatable {
    /// Expected a semicolon separator before the quality parameter.
    case expectedSemicolon
    /// Expected the `q` parameter name.
    case expectedQ
    /// The quality value is not a valid decimal between 0 and 1.
    case invalidQValue
}

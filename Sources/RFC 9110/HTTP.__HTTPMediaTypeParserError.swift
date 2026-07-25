//
//  HTTP.__HTTPMediaTypeParserError.swift
//  swift-rfc-9110
//
//  Module-scope, non-generic error for the HTTP media-type parser.
//
//  Hoisted out of the generic `RFC_9110.MediaType.Parser<Input>` namespace so the
//  `@error` SIL result carries no phantom `Input` type parameter — the structural
//  fix for the `FunctionSignatureOpts` release-build ICE
//  (`SILArgument.cpp:40 !type.hasTypeParameter()`; Research §A13 / swiftlang/swift#89617).
//  Surfaced through the public path `RFC_9110.MediaType.Parser.Error` (a typealias).
//

/// Errors that can occur when parsing an HTTP media-type.
public enum __HTTPMediaTypeParserError: Swift.Error, Sendable, Equatable {
    /// The type portion is not a valid token.
    case expectedType
    /// Expected a slash between type and subtype.
    case expectedSlash
    /// The subtype portion is not a valid token.
    case expectedSubtype
}

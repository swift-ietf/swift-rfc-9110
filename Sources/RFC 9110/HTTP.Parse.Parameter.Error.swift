//
//  HTTP.Parse.Parameter.Error.swift
//  swift-rfc-9110
//
//  Error type for HTTP parameter parser.
//

extension HTTP.Parse.Parameter {
    /// Errors that can occur when parsing an HTTP parameter (`name=value`).
    public enum Error: Swift.Error, Sendable, Equatable {
        /// The parameter name is not a valid token.
        case expectedToken
        /// Expected an equals sign between the name and value.
        case expectedEquals
        /// No valid token or quoted-string follows the equals sign.
        case expectedValue
        /// The quoted-string value is malformed.
        case invalidQuotedString(HTTP.Parse.QuotedString<Input>.Error)
    }
}

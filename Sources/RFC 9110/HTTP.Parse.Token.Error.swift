//
//  HTTP.Parse.Token.Error.swift
//  swift-rfc-9110
//
//  Error type for HTTP token parser.
//

extension HTTP.Parse.Token {
    /// Errors that can occur when parsing an HTTP token.
    public enum Error: Swift.Error, Sendable, Equatable {
        /// Input does not begin with a valid token character.
        case expectedToken
    }
}

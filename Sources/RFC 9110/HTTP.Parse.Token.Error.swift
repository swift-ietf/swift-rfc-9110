//
//  HTTP.Parse.Token.Error.swift
//  swift-rfc-9110
//
//  Public parser alias onto the canonical non-generic error.
//

extension RFC_9110.Parse.Token {
    /// Errors that can occur when parsing an HTTP token.
    public typealias Error = RFC_9110.Parse.Error.Token
}

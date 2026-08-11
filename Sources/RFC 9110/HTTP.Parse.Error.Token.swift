// HTTP.Parse.Error.Token.swift
// swift-rfc-9110

extension RFC_9110.Parse.Error {
    /// Errors that can occur when parsing an HTTP token.
    public enum Token: Swift.Error, Sendable, Equatable {
        /// Input does not begin with a valid token character.
        case expectedToken
    }
}

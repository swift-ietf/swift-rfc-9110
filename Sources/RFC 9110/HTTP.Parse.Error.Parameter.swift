// HTTP.Parse.Error.Parameter.swift
// swift-rfc-9110

extension RFC_9110.Parse.Error {
    /// Errors that can occur when parsing an HTTP parameter.
    public enum Parameter: Swift.Error, Sendable, Equatable {
        case expectedToken
        case expectedEquals
        case expectedValue
        case invalidQuotedString(RFC_9110.Parse.Error.QuotedString)
    }
}

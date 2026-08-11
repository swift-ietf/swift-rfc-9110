//
//  HTTP.Parse.QuotedString.Error.swift
//  swift-rfc-9110
//
//  Public parser alias onto the canonical non-generic error.
//

extension RFC_9110.Parse.QuotedString {
    /// Errors that can occur when parsing an HTTP quoted-string.
    public typealias Error = RFC_9110.Parse.Error.QuotedString
}

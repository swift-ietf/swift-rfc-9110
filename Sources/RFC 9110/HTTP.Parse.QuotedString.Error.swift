//
//  HTTP.Parse.QuotedString.Error.swift
//  swift-rfc-9110
//
//  Public-path alias onto the module-scope `__HTTPQuotedStringParserError`.
//

extension RFC_9110.Parse.QuotedString {
    /// Errors that can occur when parsing an HTTP quoted-string.
    public typealias Error = __HTTPQuotedStringParserError
}

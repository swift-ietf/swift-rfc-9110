//
//  HTTP.Parse.QualityValue.Error.swift
//  swift-rfc-9110
//
//  Public-path alias onto the module-scope `__HTTPQualityValueParserError`.
//

extension RFC_9110.Parse.QualityValue {
    /// Errors that can occur when parsing an HTTP quality value.
    public typealias Error = __HTTPQualityValueParserError
}

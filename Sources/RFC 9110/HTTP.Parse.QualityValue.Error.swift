//
//  HTTP.Parse.QualityValue.Error.swift
//  swift-rfc-9110
//
//  Public parser alias onto the canonical non-generic error.
//

extension RFC_9110.Parse.QualityValue {
    /// Errors that can occur when parsing an HTTP quality value.
    public typealias Error = RFC_9110.Parse.Error.QualityValue
}

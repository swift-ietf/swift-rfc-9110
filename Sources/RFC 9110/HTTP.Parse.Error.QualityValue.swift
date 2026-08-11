// HTTP.Parse.Error.QualityValue.swift
// swift-rfc-9110

extension RFC_9110.Parse.Error {
    /// Errors that can occur when parsing an HTTP quality value.
    public enum QualityValue: Swift.Error, Sendable, Equatable {
        case invalidQValue
    }
}

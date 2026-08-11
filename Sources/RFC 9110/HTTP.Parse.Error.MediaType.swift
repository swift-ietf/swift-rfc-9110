// HTTP.Parse.Error.MediaType.swift
// swift-rfc-9110

extension RFC_9110.Parse.Error {
    /// Errors that can occur when parsing an HTTP media-type.
    public enum MediaType: Swift.Error, Sendable, Equatable {
        case expectedType
        case expectedSlash
        case expectedSubtype
    }
}

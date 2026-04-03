//
//  HTTP.MediaType.Parser.Error.swift
//  swift-rfc-9110
//
//  Error type for media-type parser per RFC 9110 Section 8.3.1.
//

extension HTTP.MediaType.Parser {
    /// Errors that can occur when parsing an HTTP media-type.
    public enum Error: Swift.Error, Sendable, Equatable {
        /// The type portion is not a valid token.
        case expectedType
        /// Expected a slash between type and subtype.
        case expectedSlash
        /// The subtype portion is not a valid token.
        case expectedSubtype
    }
}

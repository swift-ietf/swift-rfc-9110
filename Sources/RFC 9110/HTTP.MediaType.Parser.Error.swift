//
//  HTTP.MediaType.Parser.Error.swift
//  swift-rfc-9110
//
//  Public parser alias onto the canonical non-generic error.
//

extension RFC_9110.MediaType.Parser {
    /// Errors that can occur when parsing an HTTP media-type.
    public typealias Error = RFC_9110.Parse.Error.MediaType
}

//
//  HTTP.Parse.Parameter.Error.swift
//  swift-rfc-9110
//
//  Public parser alias onto the canonical non-generic error.
//

extension RFC_9110.Parse.Parameter {
    /// Errors that can occur when parsing an HTTP parameter (`name=value`).
    public typealias Error = RFC_9110.Parse.Error.Parameter
}

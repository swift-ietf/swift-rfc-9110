//
//  HTTP.Parse.Parameter.Error.swift
//  swift-rfc-9110
//
//  Public-path alias onto the module-scope `__HTTPParameterParserError`.
//

extension RFC_9110.Parse.Parameter {
    /// Errors that can occur when parsing an HTTP parameter (`name=value`).
    public typealias Error = __HTTPParameterParserError
}

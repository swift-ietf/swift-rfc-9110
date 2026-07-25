//
//  HTTP.MediaType.Parser.Error.swift
//  swift-rfc-9110
//
//  Public-path alias onto the module-scope `__HTTPMediaTypeParserError`.
//

extension RFC_9110.MediaType.Parser {
    /// Errors that can occur when parsing an HTTP media-type.
    public typealias Error = __HTTPMediaTypeParserError
}

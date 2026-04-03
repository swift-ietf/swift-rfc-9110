//
//  HTTP.Parse.QualityValue.Error.swift
//  swift-rfc-9110
//
//  Error type for HTTP quality value parser.
//

extension HTTP.Parse.QualityValue {
    /// Errors that can occur when parsing an HTTP quality value.
    public enum Error: Swift.Error, Sendable, Equatable {
        /// Expected a semicolon separator before the quality parameter.
        case expectedSemicolon
        /// Expected the `q` parameter name.
        case expectedQ
        /// The quality value is not a valid decimal between 0 and 1.
        case invalidQValue
    }
}

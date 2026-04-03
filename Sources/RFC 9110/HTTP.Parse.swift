//
//  HTTP.Parse.swift
//  swift-rfc-9110
//
//  Namespace for HTTP parser combinators per RFC 9110 grammar.
//

import Parser_Primitives

extension HTTP {
    /// Parser combinators for HTTP grammar productions defined in RFC 9110.
    public enum Parse {}
}

// MARK: - String Convenience

extension HTTP.Parse {
    /// Parses comma-separated tokens from an HTTP header value.
    ///
    /// Each element between commas is parsed as an HTTP token (RFC 9110 Section 5.6.2).
    /// Elements that fail token parsing are skipped.
    ///
    /// - Parameter headerValue: The raw header value string
    /// - Returns: Array of parsed token strings
    public static func tokens(in headerValue: String) -> [String] {
        var input = Parser_Primitives.Parser.Input.Bytes(utf8: headerValue)
        return CommaSeparated<Parser_Primitives.Parser.Input.Bytes, String> { element in
            var sub = element
            guard let token = try? Token<Parser_Primitives.Parser.Input.Bytes>().parse(&sub) else {
                return nil
            }
            return String(decoding: token, as: UTF8.self)
        }.parse(&input)
    }

    /// Parses comma-separated directives of the form `token [ "=" ( token / quoted-string ) ]`.
    ///
    /// Used for Cache-Control and similar header fields where each directive
    /// is a name optionally followed by `=` and a token or quoted-string value.
    ///
    /// - Parameter headerValue: The raw header value string
    /// - Returns: Array of (name, value?) tuples
    public static func directives(in headerValue: String) -> [(name: String, value: String?)] {
        var input = Parser_Primitives.Parser.Input.Bytes(utf8: headerValue)
        return CommaSeparated<Parser_Primitives.Parser.Input.Bytes, (name: String, value: String?)> { element in
            var sub = element
            guard let nameSlice = try? Token<Parser_Primitives.Parser.Input.Bytes>().parse(&sub) else {
                return nil
            }
            let name = String(decoding: nameSlice, as: UTF8.self)

            OWS<Parser_Primitives.Parser.Input.Bytes>().parse(&sub)
            guard sub.startIndex < sub.endIndex, sub[sub.startIndex] == 0x3D else {
                return (name: name, value: nil)
            }
            sub = sub[sub.index(after: sub.startIndex)...]
            OWS<Parser_Primitives.Parser.Input.Bytes>().parse(&sub)

            if let quoted = try? QuotedString<Parser_Primitives.Parser.Input.Bytes>().parse(&sub) {
                return (name: name, value: String(decoding: quoted, as: UTF8.self))
            }
            if let tokenSlice = try? Token<Parser_Primitives.Parser.Input.Bytes>().parse(&sub) {
                return (name: name, value: String(decoding: tokenSlice, as: UTF8.self))
            }

            return (name: name, value: nil)
        }.parse(&input)
    }
}


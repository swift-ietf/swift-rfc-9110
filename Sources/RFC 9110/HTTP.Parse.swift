//
//  HTTP.Parse.swift
//  swift-rfc-9110
//
//  Namespace for HTTP parser combinators per RFC 9110 grammar.
//

public import Byte_Parser_Primitives
import Byte_Primitives_Standard_Library_Integration
import Parser_Primitives

extension RFC_9110 {
    /// Parser combinators for HTTP grammar productions defined in RFC 9110.
    public enum Parse {}
}

// MARK: - String Convenience

extension RFC_9110.Parse {
    /// Parses comma-separated tokens from an HTTP header value.
    ///
    /// Each element between commas is parsed as an HTTP token (RFC 9110 Section 5.6.2).
    /// Elements that fail token parsing are skipped.
    ///
    /// - Parameter headerValue: The raw header value string
    /// - Returns: Array of parsed token strings
    public static func tokens(in headerValue: String) -> [String] {
        var input = Byte.Input(utf8: headerValue)
        return CommaSeparated<Byte.Input, String> { element in
            var sub = element
            let token: Byte.Input
            do throws(Token<Byte.Input>.Error) {
                token = try Token<Byte.Input>().parse(&sub)
            } catch {
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
        var input = Byte.Input(utf8: headerValue)
        return CommaSeparated<Byte.Input, (name: String, value: String?)> { element in
            var sub = element
            let nameSlice: Byte.Input
            do throws(Token<Byte.Input>.Error) {
                nameSlice = try Token<Byte.Input>().parse(&sub)
            } catch {
                return nil
            }
            let name = String(decoding: nameSlice, as: UTF8.self)

            OWS<Byte.Input>().parse(&sub)
            guard sub.startIndex < sub.endIndex, sub[sub.startIndex] == 0x3D else {
                return (name: name, value: nil)
            }
            sub = sub[sub.index(after: sub.startIndex)...]
            OWS<Byte.Input>().parse(&sub)

            do throws(QuotedString<Byte.Input>.Error) {
                let quoted = try QuotedString<Byte.Input>().parse(&sub)
                return (name: name, value: String(decoding: quoted, as: UTF8.self))
            } catch {
                // fall through to token attempt
            }
            do throws(Token<Byte.Input>.Error) {
                let tokenSlice = try Token<Byte.Input>().parse(&sub)
                return (name: name, value: String(decoding: tokenSlice, as: UTF8.self))
            } catch {
                // fall through to nil value
            }

            return (name: name, value: nil)
        }.parse(&input)
    }
}

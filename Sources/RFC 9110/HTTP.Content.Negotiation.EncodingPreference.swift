// HTTP.Content.Negotiation.EncodingPreference.swift
// swift-rfc-9110
//
// RFC 9110 Section 12.5.3: Accept-Encoding
// https://www.rfc-editor.org/rfc/rfc9110.html#section-12.5.3
//
// Content encoding preference for content negotiation

import Byte_Parser_Primitives
import Parser_Primitives

// MARK: - Encoding Preference (Section 12.5.3)

extension RFC_9110.Content.Negotiation {
    /// Content encoding preference from Accept-Encoding header (RFC 9110 Section 12.5.3)
    ///
    /// Represents a content encoding with an optional quality value.
    ///
    /// ## Example
    ///
    /// ```
    /// Accept-Encoding: gzip;q=1.0, br;q=0.8, deflate;q=0.5
    /// ```
    ///
    /// ## Reference
    ///
    /// - [RFC 9110 Section 12.5.3: Accept-Encoding](https://www.rfc-editor.org/rfc/rfc9110.html#section-12.5.3)
    public struct EncodingPreference: Sendable, Equatable {
        /// The content encoding
        public let encoding: RFC_9110.Content.Encoding

        /// The quality value (defaults to 1.0)
        public let quality: QualityValue

        /// Creates an encoding preference
        ///
        /// - Parameters:
        ///   - encoding: The content encoding
        ///   - quality: The quality value (defaults to 1.0)
        public init(encoding: RFC_9110.Content.Encoding, quality: QualityValue = .default) {
            self.encoding = encoding
            self.quality = quality
        }

    }
}

extension RFC_9110.Content.Negotiation.EncodingPreference {
    /// Parses encoding preferences from an Accept-Encoding header value
    ///
    /// - Parameter headerValue: The Accept-Encoding header value
    /// - Returns: An array of encoding preferences, sorted by quality (descending)
    ///
    /// ## Example
    ///
    /// ```swift
    /// let prefs = HTTP.Content.Negotiation.EncodingPreference.parse(
    ///     "gzip;q=1.0, br;q=0.8, deflate;q=0.5"
    /// )
    /// ```
    public static func parse(_ headerValue: String) -> [Self] {
        var input = Byte.Input(utf8: headerValue)
        let preferences = RFC_9110.Parse.CommaSeparated<Byte.Input, Self> {
            element in
            var sub = element
            let token: Byte.Input
            do throws(RFC_9110.Parse.Token<Byte.Input>.Error) {
                token = try RFC_9110.Parse.Token<Byte.Input>().parse(&sub)
            } catch {
                return nil
            }
            let encoding = RFC_9110.Content.Encoding(String(decoding: token, as: UTF8.self))
            let quality: RFC_9110.Content.Negotiation.QualityValue
            switch RFC_9110.Content.Negotiation.Weight.parse(&sub) {
            case .absent:
                quality = .default

            case .value(let value):
                quality = value

            case .invalid:
                return nil
            }
            return Self(encoding: encoding, quality: quality)
        }.parse(&input)
        return preferences.sorted { $0.quality > $1.quality }
    }
}

// MARK: - CustomStringConvertible

extension RFC_9110.Content.Negotiation.EncodingPreference: CustomStringConvertible {
    public var description: String {
        if quality == .default {
            return encoding.value
        } else {
            return "\(encoding.value);q=\(quality)"
        }
    }
}

// HTTP.Content.Negotiation.LanguagePreference.swift
// swift-rfc-9110
//
// RFC 9110 Section 12.5.4: Accept-Language
// https://www.rfc-editor.org/rfc/rfc9110.html#section-12.5.4
//
// Language preference for content negotiation

public import Byte_Parser_Primitives
import Parser_Primitives

// MARK: - Language Preference (Section 12.5.4)

extension RFC_9110.Content.Negotiation {
    /// Language preference from Accept-Language header (RFC 9110 Section 12.5.4)
    ///
    /// Represents a language tag with an optional quality value.
    ///
    /// ## Example
    ///
    /// ```
    /// Accept-Language: en-US;q=1.0, fr;q=0.8, de;q=0.5
    /// ```
    ///
    /// ## Reference
    ///
    /// - [RFC 9110 Section 12.5.4: Accept-Language](https://www.rfc-editor.org/rfc/rfc9110.html#section-12.5.4)
    public struct LanguagePreference: Sendable, Equatable {
        /// The language tag, for example "en-US", "fr", or "de"
        public let language: String

        /// The quality value (defaults to 1.0)
        public let quality: QualityValue

        /// Creates a language preference
        ///
        /// - Parameters:
        ///   - language: The language tag
        ///   - quality: The quality value (defaults to 1.0)
        public init(language: String, quality: QualityValue = .default) {
            self.language = language
            self.quality = quality
        }

    }
}

extension RFC_9110.Content.Negotiation.LanguagePreference {
    /// Parses language preferences from an Accept-Language header value
    ///
    /// - Parameter headerValue: The Accept-Language header value
    /// - Returns: An array of language preferences, sorted by quality (descending)
    ///
    /// ## Example
    ///
    /// ```swift
    /// let prefs = HTTP.Content.Negotiation.LanguagePreference.parse(
    ///     "en-US;q=1.0, fr;q=0.8, *;q=0.1"
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
            let language = String(decoding: token, as: UTF8.self)
            var quality = RFC_9110.Content.Negotiation.QualityValue.default
            do throws(RFC_9110.Parse.QualityValue<Byte.Input>.Error) {
                let q = try RFC_9110.Parse.QualityValue<Byte.Input>().parse(&sub)
                quality = RFC_9110.Content.Negotiation.QualityValue(Double(q) / 1000.0)
            } catch {
                // no explicit quality supplied: keep default
            }
            return Self(language: language, quality: quality)
        }.parse(&input)
        return preferences.sorted { lhs, rhs in
            if lhs.quality.value != rhs.quality.value {
                return lhs.quality > rhs.quality
            }
            return lhs.language.count > rhs.language.count
        }
    }
}

// MARK: - CustomStringConvertible

extension RFC_9110.Content.Negotiation.LanguagePreference: CustomStringConvertible {
    public var description: String {
        if quality == .default {
            return language
        } else {
            return "\(language);q=\(quality)"
        }
    }
}

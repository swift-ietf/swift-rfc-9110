import Byte_Parser
import Parser

extension RFC_9110.Content.Negotiation {

    public struct LanguagePreference: Sendable, Equatable {

        public let language: String

        public let quality: QualityValue

        public init(language: String, quality: QualityValue = .default) {
            self.language = language
            self.quality = quality
        }

    }
}

extension RFC_9110.Content.Negotiation.LanguagePreference {

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
            let quality: RFC_9110.Content.Negotiation.QualityValue
            switch RFC_9110.Content.Negotiation.Weight.parse(&sub) {
            case .absent:
                quality = .default

            case .value(let value):
                quality = value

            case .invalid:
                return nil
            }
            return Self(language: language, quality: quality)
        }.parse(&input)
        return preferences.sorted { lhs, rhs in
            if lhs.quality != rhs.quality {
                return lhs.quality > rhs.quality
            }
            return lhs.language.count > rhs.language.count
        }
    }
}

extension RFC_9110.Content.Negotiation.LanguagePreference: CustomStringConvertible {
    public var description: String {
        if quality == .default {
            return language
        } else {
            return "\(language);q=\(quality)"
        }
    }
}

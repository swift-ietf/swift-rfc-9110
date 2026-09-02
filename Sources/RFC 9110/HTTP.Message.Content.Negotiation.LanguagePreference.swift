import Byte
import Byte_Parser
import Byte_Standard_Library_Integration
import Parser

extension RFC_9110.Message.Content.Negotiation {

    public struct LanguagePreference: Sendable, Equatable {

        public let language: String

        public let quality: QualityValue

        public init(language: String, quality: QualityValue = .default) {
            self.language = language
            self.quality = quality
        }

    }
}

extension RFC_9110.Message.Content.Negotiation.LanguagePreference {

    public static func parse(_ headerValue: String) -> [Self] {
        var input = Byte.Input(utf8: headerValue)
        let weighted = RFC_9110.Parse.CommaSeparated(
            RFC_9110.Message.Content.Negotiation.Weighted(RFC_9110.Parse.Token<Byte.Input>())
        ).parse(&input)
        let preferences = weighted.map { element in
            Self(
                language: String(decoding: element.value, as: UTF8.self),
                quality: element.quality
            )
        }
        return preferences.sorted { lhs, rhs in
            if lhs.quality != rhs.quality {
                return lhs.quality > rhs.quality
            }
            return lhs.language.count > rhs.language.count
        }
    }
}

extension RFC_9110.Message.Content.Negotiation.LanguagePreference: CustomStringConvertible {
    public var description: String {
        if quality == .default {
            return language
        } else {
            return "\(language);q=\(quality)"
        }
    }
}

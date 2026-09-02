import Byte
import Byte_Parser
import Byte_Standard_Library_Integration
import Parser

extension RFC_9110.Message.Content.Negotiation {

    public struct CharsetPreference: Sendable, Equatable {

        public let charset: String

        public let quality: QualityValue

        public init(charset: String, quality: QualityValue = .default) {
            self.charset = charset.lowercased()
            self.quality = quality
        }

    }
}

extension RFC_9110.Message.Content.Negotiation.CharsetPreference {

    public static func parse(_ headerValue: String) -> [Self] {
        var input = Byte.Input(utf8: headerValue)
        let weighted = RFC_9110.Parse.CommaSeparated(
            RFC_9110.Message.Content.Negotiation.Weighted(RFC_9110.Parse.Token<Byte.Input>())
        ).parse(&input)
        let preferences = weighted.map { element in
            Self(
                charset: String(decoding: element.value, as: UTF8.self),
                quality: element.quality
            )
        }
        return preferences.sorted { $0.quality > $1.quality }
    }
}

extension RFC_9110.Message.Content.Negotiation.CharsetPreference: CustomStringConvertible {
    public var description: String {
        if quality == .default {
            return charset
        } else {
            return "\(charset);q=\(quality)"
        }
    }
}

import Byte
import Byte_Parser
import Byte_Standard_Library_Integration
import Parser

extension RFC_9110.Message.Content.Negotiation {

    public struct EncodingPreference: Sendable, Equatable {

        public let encoding: RFC_9110.Message.Content.Encoding

        public let quality: QualityValue

        public init(encoding: RFC_9110.Message.Content.Encoding, quality: QualityValue = .default) {
            self.encoding = encoding
            self.quality = quality
        }

    }
}

extension RFC_9110.Message.Content.Negotiation.EncodingPreference {

    public static func parse(_ headerValue: String) -> [Self] {
        var input = Byte.Input(utf8: headerValue)
        let weighted = RFC_9110.Parse.CommaSeparated(
            RFC_9110.Message.Content.Negotiation.Weighted(RFC_9110.Parse.Token<Byte.Input>())
        ).parse(&input)
        let preferences = weighted.map { element in
            Self(
                encoding: RFC_9110.Message.Content.Encoding(
                    String(decoding: element.value, as: UTF8.self)
                ),
                quality: element.quality
            )
        }
        return preferences.sorted { $0.quality > $1.quality }
    }
}

extension RFC_9110.Message.Content.Negotiation.EncodingPreference: CustomStringConvertible {
    public var description: String {
        if quality == .default {
            return encoding.value
        } else {
            return "\(encoding.value);q=\(quality)"
        }
    }
}

import Byte_Parser_Primitives
import Parser_Primitives

extension RFC_9110.Content.Negotiation {

    public struct EncodingPreference: Sendable, Equatable {

        public let encoding: RFC_9110.Content.Encoding

        public let quality: QualityValue

        public init(encoding: RFC_9110.Content.Encoding, quality: QualityValue = .default) {
            self.encoding = encoding
            self.quality = quality
        }

    }
}

extension RFC_9110.Content.Negotiation.EncodingPreference {

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

extension RFC_9110.Content.Negotiation.EncodingPreference: CustomStringConvertible {
    public var description: String {
        if quality == .default {
            return encoding.value
        } else {
            return "\(encoding.value);q=\(quality)"
        }
    }
}

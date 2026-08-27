import Byte_Parser
import Parser

extension RFC_9110.Content.Negotiation {

    public struct CharsetPreference: Sendable, Equatable {

        public let charset: String

        public let quality: QualityValue

        public init(charset: String, quality: QualityValue = .default) {
            self.charset = charset.lowercased()
            self.quality = quality
        }

    }
}

extension RFC_9110.Content.Negotiation.CharsetPreference {

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
            let quality: RFC_9110.Content.Negotiation.QualityValue
            switch RFC_9110.Content.Negotiation.Weight.parse(&sub) {
            case .absent:
                quality = .default

            case .value(let value):
                quality = value

            case .invalid:
                return nil
            }
            return Self(
                charset: String(decoding: token, as: UTF8.self),
                quality: quality
            )
        }.parse(&input)
        return preferences.sorted { $0.quality > $1.quality }
    }
}

extension RFC_9110.Content.Negotiation.CharsetPreference: CustomStringConvertible {
    public var description: String {
        if quality == .default {
            return charset
        } else {
            return "\(charset);q=\(quality)"
        }
    }
}

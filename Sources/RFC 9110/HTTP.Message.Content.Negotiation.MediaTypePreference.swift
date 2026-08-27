import Byte_Parser_Primitives
import Parser_Primitives

extension RFC_9110.Message.Content.Negotiation {

    public struct MediaTypePreference: Sendable, Equatable {

        public let mediaType: RFC_9110.MediaType

        public let quality: QualityValue

        public init(mediaType: RFC_9110.MediaType, quality: QualityValue = .default) {
            self.mediaType = mediaType
            self.quality = quality
        }

    }
}

extension RFC_9110.Message.Content.Negotiation.MediaTypePreference {

    public static func parse(_ headerValue: String) -> [Self] {
        var input = Byte.Input(utf8: headerValue)
        let preferences = RFC_9110.Parse.CommaSeparated<Byte.Input, Self> {
            element in
            var sub = element
            let mediaType: RFC_9110.MediaType
            do throws(RFC_9110.MediaType.Parser<Byte.Input>.Error) {
                mediaType = try RFC_9110.MediaType.Parser<Byte.Input>().parse(&sub)
            } catch {
                return nil
            }
            guard sub.isEmpty else { return nil }
            let quality: RFC_9110.Message.Content.Negotiation.QualityValue
            switch RFC_9110.Message.Content.Negotiation.Weight.parse(parameter: mediaType.parameters["q"]) {
            case .absent:
                quality = .default

            case .value(let value):
                quality = value

            case .invalid:
                return nil
            }

            var params = mediaType.parameters
            params.removeValue(forKey: "q")
            let cleanMediaType = RFC_9110.MediaType(
                mediaType.type,
                mediaType.subtype,
                parameters: params
            )
            return Self(mediaType: cleanMediaType, quality: quality)
        }.parse(&input)

        return preferences.sorted { lhs, rhs in
            if lhs.quality != rhs.quality {
                return lhs.quality > rhs.quality
            }
            if lhs.mediaType.type == "*" && rhs.mediaType.type != "*" { return false }
            if lhs.mediaType.type != "*" && rhs.mediaType.type == "*" { return true }
            if lhs.mediaType.subtype == "*" && rhs.mediaType.subtype != "*" { return false }
            if lhs.mediaType.subtype != "*" && rhs.mediaType.subtype == "*" { return true }
            return false
        }
    }
}

extension RFC_9110.Message.Content.Negotiation.MediaTypePreference: CustomStringConvertible {
    public var description: String {
        if quality == .default {
            return mediaType.value
        } else {
            return "\(mediaType.value);q=\(quality)"
        }
    }
}

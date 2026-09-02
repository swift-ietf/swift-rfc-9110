import ASCII
import Byte
import Byte_Parser
import Parser
import Standard_Library_Extensions

extension RFC_9110 {

    public struct MediaType: Sendable, Equatable, Hashable, Codable {

        public let type: String

        public let subtype: String

        public var parameters: [String: String]

        public init(_ type: String, _ subtype: String, parameters: [String: String] = [:]) {
            self.type = type.lowercased()
            self.subtype = subtype.lowercased()
            self.parameters = parameters
        }

    }
}

extension RFC_9110.MediaType {

    public var value: String {
        var result = "\(type)/\(subtype)"

        if !parameters.isEmpty {
            let params =
                parameters
                .sorted { $0.key < $1.key }
                .map { "\($0.key)=\($0.value)" }
                .joined(separator: "; ")
            result += "; \(params)"
        }

        return result
    }

    public static func parse(_ string: String) -> Self? {
        var input = Byte.Input(utf8: string)
        do throws(Parser<Byte.Input>.Error) {
            return try Parser<Byte.Input>().parse(&input)
        } catch {
            return nil
        }
    }

    public func matches(_ pattern: String) -> Bool {
        guard let patternType = Self.parse(pattern) else {
            return false
        }

        return matches(patternType)
    }

    public func matches(_ other: Self) -> Bool {

        if other.type == "*" && other.subtype == "*" {
            return true
        }

        if other.type == type && other.subtype == "*" {
            return true
        }

        return type == other.type && subtype == other.subtype
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.type == rhs.type && lhs.subtype == rhs.subtype
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(type)
        hasher.combine(subtype)
    }
}

extension RFC_9110.MediaType: CustomStringConvertible {
    public var description: String {
        value
    }
}

extension RFC_9110.MediaType: LosslessStringConvertible {

    public init?(_ description: String) {
        guard let parsed = Self.parse(description) else { return nil }
        self = parsed
    }
}

extension RFC_9110.MediaType {
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)

        guard let mediaType = RFC_9110.MediaType.parse(string) else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid media type: \(string)"
            )
        }

        self = mediaType
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }
}

extension RFC_9110.MediaType: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        if let parsed = RFC_9110.MediaType.parse(value) {
            self = parsed
        } else {

            self = RFC_9110.MediaType("application", "octet-stream")
        }
    }
}

extension RFC_9110.MediaType {

    public static let plain = RFC_9110.MediaType("text", "plain")

    public static let html = RFC_9110.MediaType("text", "html")

    public static let css = RFC_9110.MediaType("text", "css")

    public static let csv = RFC_9110.MediaType("text", "csv")

    public static let xml = RFC_9110.MediaType("text", "xml")

    public static let json = RFC_9110.MediaType("application", "json")

    public static let xmlApp = RFC_9110.MediaType("application", "xml")

    public static let pdf = RFC_9110.MediaType("application", "pdf")

    public static let zip = RFC_9110.MediaType("application", "zip")

    public static let gzip = RFC_9110.MediaType("application", "gzip")

    public static let octetStream = RFC_9110.MediaType("application", "octet-stream")

    public static let formUrlEncoded = RFC_9110.MediaType("application", "x-www-form-urlencoded")

    public static let formData = RFC_9110.MediaType("multipart", "form-data")

    public static let jpeg = RFC_9110.MediaType("image", "jpeg")

    public static let png = RFC_9110.MediaType("image", "png")

    public static let gif = RFC_9110.MediaType("image", "gif")

    public static let svg = RFC_9110.MediaType("image", "svg+xml")

    public static let webp = RFC_9110.MediaType("image", "webp")

    public static let ico = RFC_9110.MediaType("image", "x-icon")

    public static let mp3 = RFC_9110.MediaType("audio", "mpeg")

    public static let wav = RFC_9110.MediaType("audio", "wav")

    public static let oggAudio = RFC_9110.MediaType("audio", "ogg")

    public static let mp4 = RFC_9110.MediaType("video", "mp4")

    public static let webm = RFC_9110.MediaType("video", "webm")

    public static let oggVideo = RFC_9110.MediaType("video", "ogg")

    public static let woff = RFC_9110.MediaType("font", "woff")

    public static let woff2 = RFC_9110.MediaType("font", "woff2")

    public static let ttf = RFC_9110.MediaType("font", "ttf")

    public static let otf = RFC_9110.MediaType("font", "otf")
}

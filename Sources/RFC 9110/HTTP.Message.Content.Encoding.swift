extension RFC_9110.Message.Content {

    public struct Encoding: Sendable, Equatable, Hashable, Codable {

        public let value: String

        public init(_ value: String) {
            self.value = value.lowercased()
        }
    }
}

extension RFC_9110.Message.Content.Encoding {

    public static func formatHeader(_ encodings: [Self]) -> String {
        encodings.map(\.value).joined(separator: ", ")
    }
}

extension RFC_9110.Message.Content.Encoding: CustomStringConvertible {
    public var description: String {
        value
    }
}

extension RFC_9110.Message.Content.Encoding {
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        self.init(value)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }
}

extension RFC_9110.Message.Content.Encoding: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(value)
    }
}

extension RFC_9110.Message.Content.Encoding {

    public static let gzip = Self("gzip")

    public static let deflate = Self("deflate")

    public static let compress = Self("compress")

    public static let brotli = Self("br")

    public static let identity = Self("identity")
}

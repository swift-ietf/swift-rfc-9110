extension IETF.RFC.`9110`.Representation {

    public struct Encoding: Sendable, Equatable, Hashable {

        public let value: String

        public init(_ value: String) {
            self.value = value.lowercased()
        }
    }
}

extension IETF.RFC.`9110`.Representation.Encoding {

    public static func formatHeader(_ encodings: [Self]) -> String {
        encodings.map { $0.value }.joined(separator: ", ")
    }
}

extension IETF.RFC.`9110`.Representation.Encoding: CustomStringConvertible {
    public var description: String {
        value
    }
}

#if !hasFeature(Embedded)
extension IETF.RFC.`9110`.Representation.Encoding: Codable {
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
#endif

extension IETF.RFC.`9110`.Representation.Encoding: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(value)
    }
}

extension IETF.RFC.`9110`.Representation.Encoding {

    public static let gzip = Self("gzip")

    public static let deflate = Self("deflate")

    public static let compress = Self("compress")

    public static let brotli = Self("br")

    public static let identity = Self("identity")
}

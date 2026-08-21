extension RFC_9110.Authentication {

    public struct Scheme: Sendable, Equatable, Hashable {

        public let name: String

        public init(_ name: String) {
            self.name = name
        }

    }
}

extension RFC_9110.Authentication.Scheme {

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.name.lowercased() == rhs.name.lowercased()
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(name.lowercased())
    }
}

extension RFC_9110.Authentication.Scheme: CustomStringConvertible {
    public var description: String {
        name
    }
}

extension RFC_9110.Authentication.Scheme: Codable {
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let name = try container.decode(String.self)
        self.init(name)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(name)
    }
}

extension RFC_9110.Authentication.Scheme: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(value)
    }
}

extension RFC_9110.Authentication.Scheme {

    public static let basic = Self("Basic")

    public static let bearer = Self("Bearer")

    public static let digest = Self("Digest")

    public static let negotiate = Self("Negotiate")

    public static let oauth = Self("OAuth")
}

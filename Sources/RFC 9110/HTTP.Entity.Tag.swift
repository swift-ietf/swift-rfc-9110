import ASCII
import Byte
import Byte_Parser
import Byte_Standard_Library_Integration
import Parser
import Standard_Library_Extensions

extension RFC_9110.Entity {

    public struct Tag: Sendable, Equatable, Hashable, Codable {

        public let value: String

        public let isWeak: Bool

        public init(value: String, isWeak: Bool = false) {
            self.value = value
            self.isWeak = isWeak
        }

    }
}

extension RFC_9110.Entity.Tag {

    public var headerValue: String {
        if isWeak {
            return "W/\"\(value)\""
        } else {
            return "\"\(value)\""
        }
    }

    public static func parse(_ headerValue: String) -> Self? {
        var input = Byte.Input(utf8: headerValue)
        do throws(RFC_9110.Parse.Error.QuotedString) {
            return try Parser<Byte.Input>().parse(&input)
        } catch {
            return nil
        }
    }
}

extension RFC_9110.Entity.Tag: CustomStringConvertible {
    public var description: String {
        headerValue
    }
}

extension RFC_9110.Entity.Tag {
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)

        guard let entityTag = RFC_9110.Entity.Tag.parse(string) else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid entity tag: \(string)"
            )
        }

        self = entityTag
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(headerValue)
    }
}

extension RFC_9110.Entity.Tag: LosslessStringConvertible {

    public init?(_ description: String) {
        guard let parsed = Self.parse(description) else { return nil }
        self = parsed
    }
}

extension RFC_9110.Entity.Tag: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        if let parsed = RFC_9110.Entity.Tag.parse(value) {
            self = parsed
        } else {

            self = RFC_9110.Entity.Tag(value: value, isWeak: false)
        }
    }
}

extension RFC_9110.Entity.Tag {

    public static func strong(_ value: String) -> Self {
        Self(value: value, isWeak: false)
    }

    public static func weak(_ value: String) -> Self {
        Self(value: value, isWeak: true)
    }

    public static func strongCompare(_ lhs: Self, _ rhs: Self) -> Bool {
        !lhs.isWeak && !rhs.isWeak && lhs.value == rhs.value
    }

    public static func weakCompare(_ lhs: Self, _ rhs: Self) -> Bool {
        lhs.value == rhs.value
    }
}

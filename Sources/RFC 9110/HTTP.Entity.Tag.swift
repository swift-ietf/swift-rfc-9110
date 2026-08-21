import ASCII_Primitives
import Byte_Parser_Primitives
import Byte_Primitives_Standard_Library_Integration
import Parser_Primitives
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

        RFC_9110.Parse.OWS<Byte.Input>().parse(&input)

        var isWeak = false
        if input.startIndex < input.endIndex, input[input.startIndex] == 0x57 {
            let next = input.index(after: input.startIndex)
            if next < input.endIndex, input[next] == 0x2F {
                input = input[input.index(after: next)...]
                isWeak = true
            }
        }

        let bytes: [Byte]
        do throws(RFC_9110.Parse.QuotedString<Byte.Input>.Error) {
            bytes = try RFC_9110.Parse.QuotedString<Byte.Input>().parse(&input)
        } catch {
            return nil
        }

        return Self(value: String(decoding: bytes, as: UTF8.self), isWeak: isWeak)
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

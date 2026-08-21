import ASCII_Primitives
import Standard_Library_Extensions

extension RFC_9110.Content {

    public struct Language: Sendable, Equatable, Hashable {

        public let tag: String

        public init(_ tag: String) {

            self.tag = tag.lowercased()
        }

    }
}

extension RFC_9110.Content.Language {

    public static func parse(_ headerValue: String) -> [Self] {
        RFC_9110.Parse.tokens(in: headerValue).map { Self($0) }
    }

    public static func formatHeader(_ languages: [Self]) -> String {
        return
            languages
            .map { $0.tag }
            .joined(separator: ", ")
    }
}

extension RFC_9110.Content.Language: Codable {
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let tag = try container.decode(String.self)
        self.init(tag)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(tag)
    }
}

extension RFC_9110.Content.Language: CustomStringConvertible {
    public var description: String {
        return tag
    }
}

extension RFC_9110.Content.Language: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(value)
    }
}

extension RFC_9110.Content.Language {

    public static let english = Self("en")

    public static let englishUS = Self("en-US")

    public static let englishUK = Self("en-GB")

    public static let french = Self("fr")

    public static let frenchCA = Self("fr-CA")

    public static let german = Self("de")

    public static let spanish = Self("es")

    public static let italian = Self("it")

    public static let japanese = Self("ja")

    public static let chineseSimplified = Self("zh-Hans")

    public static let chineseTraditional = Self("zh-Hant")

    public static let portuguese = Self("pt")

    public static let dutch = Self("nl")

    public static let russian = Self("ru")
}

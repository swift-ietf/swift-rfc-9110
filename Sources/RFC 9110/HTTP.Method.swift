extension RFC_9110 {

    public struct Method: Hashable, Sendable, Codable, RawRepresentable {

        public let rawValue: String

        public let isSafe: Bool

        public let isIdempotent: Bool

        public let isCacheable: Bool

        public init(
            _ rawValue: String,
            isSafe: Bool,
            isIdempotent: Bool,
            isCacheable: Bool
        ) {
            self.rawValue = rawValue
            self.isSafe = isSafe
            self.isIdempotent = isIdempotent
            self.isCacheable = isCacheable
        }

        public init(rawValue: String) {
            switch rawValue {
            case "GET":
                self = .get

            case "HEAD":
                self = .head

            case "POST":
                self = .post

            case "PUT":
                self = .put

            case "DELETE":
                self = .delete

            case "CONNECT":
                self = .connect

            case "OPTIONS":
                self = .options

            case "TRACE":
                self = .trace

            case "PATCH":
                self = .patch

            default:

                self.init(rawValue, isSafe: false, isIdempotent: false, isCacheable: false)
            }
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.singleValueContainer()
            let rawValue = try container.decode(String.self)

            let standardMethods: [Method] = [
                .get, .head, .post, .put, .delete,
                .connect, .options, .trace, .patch,
            ]

            if let standard = standardMethods.first(where: { $0.rawValue == rawValue }) {
                self = standard
            } else {

                self.init(rawValue: rawValue)
            }
        }

    }
}

extension RFC_9110.Method {

    public static func == (lhs: Self, rhs: Self) -> Bool {

        lhs.rawValue == rhs.rawValue && lhs.isSafe == rhs.isSafe
            && lhs.isIdempotent == rhs.isIdempotent && lhs.isCacheable == rhs.isCacheable
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
        hasher.combine(isSafe)
        hasher.combine(isIdempotent)
        hasher.combine(isCacheable)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

extension RFC_9110.Method {

    public static let get = Self("GET", isSafe: true, isIdempotent: true, isCacheable: true)

    public static let head = Self("HEAD", isSafe: true, isIdempotent: true, isCacheable: true)

    public static let post = Self("POST", isSafe: false, isIdempotent: false, isCacheable: true)

    public static let put = Self("PUT", isSafe: false, isIdempotent: true, isCacheable: false)

    public static let delete = Self("DELETE", isSafe: false, isIdempotent: true, isCacheable: false)

    public static let connect = Self(
        "CONNECT",
        isSafe: false,
        isIdempotent: false,
        isCacheable: false
    )

    public static let options = Self(
        "OPTIONS",
        isSafe: true,
        isIdempotent: true,
        isCacheable: false
    )

    public static let trace = Self("TRACE", isSafe: true, isIdempotent: true, isCacheable: false)

    public static let patch = Self("PATCH", isSafe: false, isIdempotent: false, isCacheable: false)
}

extension RFC_9110.Method: CustomStringConvertible {
    public var description: String {
        rawValue
    }
}

extension RFC_9110.Method: LosslessStringConvertible {

    public init?(_ description: String) {
        self.init(rawValue: description)
    }
}

extension RFC_9110.Method: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(rawValue: value)
    }
}

extension RFC_9110.Method: CaseIterable {

    public static var allCases: [RFC_9110.Method] {
        [.get, .head, .post, .put, .delete, .connect, .options, .trace, .patch]
    }
}

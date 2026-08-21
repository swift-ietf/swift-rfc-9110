extension RFC_9110.Header.Field {

    public struct Value: Hashable, Sendable, Codable {

        public let rawValue: String

        public init(_ rawValue: String) throws(Error) {

            if rawValue.utf8.contains(0x0D) {
                throw Error.invalidFieldValue(
                    value: rawValue,
                    reason:
                        "Header field value contains CR (carriage return) character, forbidden by RFC 9110 §5.5"
                )
            }

            if rawValue.utf8.contains(0x0A) {
                throw Error.invalidFieldValue(
                    value: rawValue,
                    reason:
                        "Header field value contains LF (line feed) character, forbidden by RFC 9110 §5.5"
                )
            }

            self.rawValue = rawValue
        }

        public init(unchecked rawValue: String) {
            self.rawValue = rawValue
        }
    }
}

extension RFC_9110.Header.Field.Value: CustomStringConvertible {
    public var description: String {
        rawValue
    }
}

extension RFC_9110.Header.Field.Value {
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        try self.init(rawValue)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

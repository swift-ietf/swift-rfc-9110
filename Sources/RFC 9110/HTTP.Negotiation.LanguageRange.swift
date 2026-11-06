extension RFC_9110.Negotiation {

    /// A basic language range from RFC 4647 section 2.1, which Accept-Language carries: `*`, or subtags such as `en-GB`.
    public struct LanguageRange: Sendable, Equatable, Hashable {

        public let value: String

        public init(_ value: String) throws(Error) {
            guard !value.isEmpty else { throw .empty }
            guard value != "*" else {
                self.value = value
                return
            }
            var isFirstSubtag = true
            var subtagLength = 0
            for byte in value.utf8 {
                switch byte {
                case 0x2D:
                    guard subtagLength > 0 else { throw .invalid(value) }
                    isFirstSubtag = false
                    subtagLength = 0

                case 0x41...0x5A, 0x61...0x7A:
                    guard subtagLength < 8 else { throw .invalid(value) }
                    subtagLength += 1

                case 0x30...0x39:
                    guard !isFirstSubtag, subtagLength < 8 else { throw .invalid(value) }
                    subtagLength += 1

                default:
                    throw .invalid(value)
                }
            }
            guard subtagLength > 0 else { throw .invalid(value) }
            self.value = value
        }

        /// A field value's token as it came off the wire, which a peer may have sent outside the grammar, such as `en_US`.
        public init(unchecked value: String) {
            self.value = value
        }
    }
}

extension RFC_9110.Negotiation.LanguageRange {

    public static let any = Self(unchecked: "*")
}

extension RFC_9110.Negotiation.LanguageRange: CustomStringConvertible {

    public var description: String {
        value
    }
}

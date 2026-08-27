extension RFC_9110.Field {

    public struct Value: Hashable {

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

extension RFC_9110.Field.Value: CustomStringConvertible {
    public var description: String {
        rawValue
    }
}

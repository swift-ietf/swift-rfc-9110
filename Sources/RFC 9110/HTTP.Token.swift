extension RFC_9110 {

    public struct Token: Hashable {

        public let rawValue: String

        public init(_ rawValue: String) throws(Error) {
            guard !rawValue.isEmpty else { throw .empty }
            for byte in rawValue.utf8 where !Self.isTchar(byte) {
                throw .invalidCharacter(byte)
            }
            self.rawValue = rawValue
        }

        public init(unchecked rawValue: String) {
            self.rawValue = rawValue
        }
    }
}

extension RFC_9110.Token {

    public enum Error: Swift.Error, Equatable {
        case empty
        case invalidCharacter(UInt8)
    }
}

extension RFC_9110.Token {

    public static func isTchar(_ byte: UInt8) -> Bool {
        switch byte {
        case 0x21, 0x23, 0x24, 0x25, 0x26, 0x27, 0x2A, 0x2B,
            0x2D, 0x2E, 0x5E, 0x5F, 0x60, 0x7C, 0x7E,
            0x30...0x39, 0x41...0x5A, 0x61...0x7A:
            true

        default:
            false
        }
    }
}

extension RFC_9110.Token: CustomStringConvertible {

    public var description: String {
        rawValue
    }
}

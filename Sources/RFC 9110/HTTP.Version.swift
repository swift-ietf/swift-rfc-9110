extension RFC_9110 {
    public struct Version: Equatable, Hashable, Comparable {
        public let major: UInt
        public let minor: UInt

        public init(major: UInt, minor: UInt) throws(Error) {
            guard major < 10 else {
                throw .invalid(major)
            }
            guard minor < 10 else {
                throw .invalid(minor)
            }
            self.major = major
            self.minor = minor
        }
    }
}

extension RFC_9110.Version {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.major == rhs.major
            ? lhs.minor < rhs.minor
            : lhs.major < rhs.major
    }
}

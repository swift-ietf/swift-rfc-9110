extension RFC_9110.Representation.Validator {

    public struct EntityTag: Sendable, Equatable, Hashable {

        public let value: String

        public let isWeak: Bool

        public init(value: String, isWeak: Bool = false) {
            self.value = value
            self.isWeak = isWeak
        }

    }
}

extension RFC_9110.Representation.Validator.EntityTag {

    public var headerValue: String {
        if isWeak {
            return "W/\"\(value)\""
        } else {
            return "\"\(value)\""
        }
    }
}

extension RFC_9110.Representation.Validator.EntityTag: CustomStringConvertible {
    public var description: String {
        headerValue
    }
}

extension RFC_9110.Representation.Validator.EntityTag {

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

extension RFC_9110.Negotiation {

    public struct Vary: Sendable, Equatable, Hashable, Codable {

        public let fieldNames: [String]

        public let variesOnAllAspects: Bool

        public init(fieldNames: [String]) {
            self.fieldNames = fieldNames.map { $0.lowercased() }
            self.variesOnAllAspects = false
        }

        private init() {
            self.fieldNames = []
            self.variesOnAllAspects = true
        }
    }
}

extension RFC_9110.Negotiation.Vary {

    public static let all = RFC_9110.Negotiation.Vary()

    public var headerValue: String {
        if variesOnAllAspects {
            return "*"
        }
        return fieldNames.joined(separator: ", ")
    }

    public func includes(_ fieldName: String) -> Bool {
        if variesOnAllAspects {
            return true
        }
        return fieldNames.contains(fieldName.lowercased())
    }

    public func matches(
        requestHeaders: [String: String],
        cachedRequestHeaders: [String: String]
    ) -> Bool {
        if variesOnAllAspects {
            return false
        }

        for fieldName in fieldNames {
            let requestValue = requestHeaders[fieldName]
            let cachedValue = cachedRequestHeaders[fieldName]

            if requestValue != cachedValue {
                return false
            }
        }

        return true
    }
}

extension RFC_9110.Negotiation.Vary: CustomStringConvertible {
    public var description: String {
        headerValue
    }
}

extension RFC_9110.Negotiation.Vary: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: String...) {
        self.init(fieldNames: elements)
    }
}

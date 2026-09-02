extension RFC_9110 {

    public struct Parameter: Hashable {

        public let name: Token

        public var value: String

        public init(name: Token, value: String) {
            self.name = name
            self.value = value
        }
    }
}

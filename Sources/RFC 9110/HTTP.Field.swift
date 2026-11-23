extension IETF.RFC.`9110` {

    public struct Field: Sendable, Hashable {

        public let name: Name

        public let value: Value

        public init(name: Name, value: Value) {
            self.name = name
            self.value = value
        }

        public init(name: String, value: String) throws(Error) {
            do throws(Name.Error) {
                self.name = try Name(name)
            } catch {
                throw .invalidFieldName(error)
            }
            self.value = try Value(value)
        }
    }
}

extension IETF.RFC.`9110`.Field: CustomStringConvertible {

    public var description: String {
        "\(name): \(value)"
    }
}

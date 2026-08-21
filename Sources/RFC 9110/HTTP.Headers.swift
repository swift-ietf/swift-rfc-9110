extension RFC_9110 {

    public struct Headers: Sendable, Equatable, Hashable, Codable {

        var storage: [Header.Field.Name: [Header.Field.Value]]

        var orderedNames: [Header.Field.Name]

        public init(_ fields: [Header.Field] = []) {
            var storage: [Header.Field.Name: [Header.Field.Value]] = [:]
            var orderedNames: [Header.Field.Name] = []

            for field in fields {
                if storage[field.name] == nil {
                    orderedNames.append(field.name)
                    storage[field.name] = [field.value]
                } else {
                    storage[field.name]?.append(field.value)
                }
            }

            self.storage = storage
            self.orderedNames = orderedNames
        }
    }
}

extension RFC_9110.Headers {

    public subscript(_ name: String) -> [RFC_9110.Header.Field.Value]? {
        do throws(RFC_9110.Header.Field.Name.Error) {
            return self[try RFC_9110.Header.Field.Name(name)]
        } catch {
            return nil
        }
    }

    public subscript(_ name: RFC_9110.Header.Field.Name) -> [RFC_9110.Header.Field.Value]? {
        storage[name]
    }

    public var isEmpty: Bool {
        storage.isEmpty
    }

    public var count: Int {
        storage.count
    }

    public func first(_ name: String) -> RFC_9110.Header.Field.Value? {
        self[name]?.first
    }

    public func values(_ name: String) -> [RFC_9110.Header.Field.Value] {
        self[name] ?? []
    }

    public func contains(_ name: String) -> Bool {
        self[name] != nil
    }
}

extension RFC_9110.Headers {

    public mutating func append(_ field: RFC_9110.Header.Field) {
        if storage[field.name] == nil {
            orderedNames.append(field.name)
            storage[field.name] = [field.value]
        } else {
            storage[field.name]?.append(field.value)
        }
    }

    public mutating func removeAll(named name: String) {
        do throws(RFC_9110.Header.Field.Name.Error) {
            removeAll(named: try RFC_9110.Header.Field.Name(name))
        } catch {}
    }

    public mutating func removeAll(named name: RFC_9110.Header.Field.Name) {
        storage.removeValue(forKey: name)
        orderedNames.removeAll { $0 == name }
    }
}

extension RFC_9110.Headers: ExpressibleByArrayLiteral {

    public init(arrayLiteral elements: RFC_9110.Header.Field...) {
        self.init(elements)
    }
}

extension RFC_9110.Headers: CustomStringConvertible {

    public var description: String {
        map(\.description).joined(separator: "\n")
    }
}

extension RFC_9110.Headers {
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let fields = try container.decode([RFC_9110.Header.Field].self)
        self.init(fields)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()

        try container.encode(Array(self))
    }
}

extension RFC_9110.Headers: CustomDebugStringConvertible {

    public var debugDescription: String {
        let headerLines = map { "  \($0.name): \($0.value)" }
            .joined(separator: "\n")

        if isEmpty {
            return "HTTP.Headers(0 fields)"
        } else {
            return """
                HTTP.Headers(\(count) field\(count == 1 ? "" : "s")):
                \(headerLines)
                """
        }
    }
}

extension RFC_9110.Message {
    public struct Headers: Equatable, Hashable {
        package var fields: [RFC_9110.Field]

        public init(_ fields: [RFC_9110.Field] = []) {
            self.fields = fields
        }
    }
}

extension RFC_9110.Message.Headers {
    public subscript(_ name: RFC_9110.Field.Name) -> [RFC_9110.Field.Value] {
        fields.compactMap { $0.name == name ? $0.value : nil }
    }

    public var isEmpty: Bool {
        fields.isEmpty
    }

    public var count: Int {
        fields.count
    }

    public func values(_ name: RFC_9110.Field.Name) -> [RFC_9110.Field.Value] {
        self[name]
    }

    public mutating func append(_ field: RFC_9110.Field) {
        fields.append(field)
    }

    public mutating func remove(_ name: RFC_9110.Field.Name) {
        fields.removeAll { $0.name == name }
    }
}

extension RFC_9110.Message.Headers: RandomAccessCollection {
    public typealias Index = Array<RFC_9110.Field>.Index

    public var startIndex: Index {
        fields.startIndex
    }

    public var endIndex: Index {
        fields.endIndex
    }

    public subscript(_ index: Index) -> RFC_9110.Field {
        fields[index]
    }
}

extension RFC_9110.Message.Headers: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: RFC_9110.Field...) {
        self.init(elements)
    }
}

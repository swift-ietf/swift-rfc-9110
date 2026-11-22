extension IETF.RFC.`9110`.Message {
    public struct Trailers: Sendable, Equatable, Hashable {
        package var fields: [IETF.RFC.`9110`.Field]

        public init(_ fields: [IETF.RFC.`9110`.Field] = []) {
            self.fields = fields
        }
    }
}

extension IETF.RFC.`9110`.Message.Trailers {
    public subscript(_ name: IETF.RFC.`9110`.Field.Name) -> [IETF.RFC.`9110`.Field.Value] {
        fields.compactMap { $0.name == name ? $0.value : nil }
    }

    public var isEmpty: Bool {
        fields.isEmpty
    }

    public var count: Int {
        fields.count
    }

    public func values(_ name: IETF.RFC.`9110`.Field.Name) -> [IETF.RFC.`9110`.Field.Value] {
        self[name]
    }

    public mutating func append(_ field: IETF.RFC.`9110`.Field) {
        fields.append(field)
    }

    public mutating func remove(_ name: IETF.RFC.`9110`.Field.Name) {
        fields.removeAll { $0.name == name }
    }
}

extension IETF.RFC.`9110`.Message.Trailers: RandomAccessCollection {
    public typealias Index = Array<IETF.RFC.`9110`.Field>.Index

    public var startIndex: Index {
        fields.startIndex
    }

    public var endIndex: Index {
        fields.endIndex
    }

    public subscript(_ index: Index) -> IETF.RFC.`9110`.Field {
        fields[index]
    }
}

extension IETF.RFC.`9110`.Message.Trailers: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: IETF.RFC.`9110`.Field...) {
        self.init(elements)
    }
}

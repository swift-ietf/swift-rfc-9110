extension RFC_9110.Headers: Swift.Sequence {

    public struct Iterator: IteratorProtocol {
        private var nameIndex = 0
        private var valueIndex = 0
        private let orderedNames: [RFC_9110.Header.Field.Name]
        private let storage: [RFC_9110.Header.Field.Name: [RFC_9110.Header.Field.Value]]

        init(
            orderedNames: [RFC_9110.Header.Field.Name],
            storage: [RFC_9110.Header.Field.Name: [RFC_9110.Header.Field.Value]]
        ) {
            self.orderedNames = orderedNames
            self.storage = storage
        }

    }

    public func makeIterator() -> Iterator {
        Iterator(orderedNames: orderedNames, storage: storage)
    }
}

extension RFC_9110.Headers.Iterator {
    public mutating func next() -> RFC_9110.Header.Field? {
        guard nameIndex < orderedNames.count else { return nil }

        let name = orderedNames[nameIndex]
        let values = storage[name]!

        guard valueIndex < values.count else {
            nameIndex += 1
            valueIndex = 0
            return next()
        }

        let value = values[valueIndex]
        valueIndex += 1

        return RFC_9110.Header.Field(name: name, value: value)
    }
}

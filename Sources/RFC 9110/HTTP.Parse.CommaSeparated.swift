public import Byte_Parser
import Parser

extension RFC_9110.Parse {

    public struct CommaSeparated<Input: Collection.Slice.`Protocol`, T: Sendable>: Sendable
    where Input: Sendable, Input.Element == Byte {
        @usableFromInline
        let transform: @Sendable (Input) -> T?

        @inlinable
        public init(_ transform: @escaping @Sendable (Input) -> T?) {
            self.transform = transform
        }
    }
}

extension RFC_9110.Parse.CommaSeparated: Parser.`Protocol` {
    public typealias Output = [T]
    public typealias Failure = Never
    public typealias Body = Never

    @inlinable
    public func parse(_ input: inout Input) -> [T] {
        var results: [T] = []

        RFC_9110.Parse.OWS<Input>().parse(&input)
        if let first = _parseElement(&input) {
            results.append(first)
        }

        while input.startIndex < input.endIndex {
            RFC_9110.Parse.OWS<Input>().parse(&input)
            guard input.startIndex < input.endIndex, input[input.startIndex] == 0x2C else {
                break
            }
            input = input[input.index(after: input.startIndex)...]
            RFC_9110.Parse.OWS<Input>().parse(&input)

            if let element = _parseElement(&input) {
                results.append(element)
            }
        }

        return results
    }

    @inlinable
    package func _parseElement(_ input: inout Input) -> T? {

        var index = input.startIndex
        while index < input.endIndex {
            let byte = input[index]
            if byte == 0x2C { break }
            input.formIndex(after: &index)
        }
        let element = input[input.startIndex..<index]
        input = input[index...]

        guard !element.isEmpty else { return nil }

        var lastNonWS = element.startIndex
        var hasContent = false
        var idx = element.startIndex
        while idx < element.endIndex {
            let b = element[idx]
            if b != 0x20 && b != 0x09 {
                lastNonWS = element.index(after: idx)
                hasContent = true
            }
            element.formIndex(after: &idx)
        }

        if !hasContent { return nil }

        let trimmed = element[element.startIndex..<lastNonWS]
        return transform(trimmed)
    }
}

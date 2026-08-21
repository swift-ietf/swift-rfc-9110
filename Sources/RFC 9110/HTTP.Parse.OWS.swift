public import Byte_Parser_Primitives
import Parser_Primitives

extension RFC_9110.Parse {

    public struct OWS<Input: Collection.Slice.`Protocol`>: Sendable
    where Input: Sendable, Input.Element == Byte {
        @inlinable
        public init() {}
    }
}

extension RFC_9110.Parse.OWS: Parser.`Protocol` {
    public typealias Output = Void
    public typealias Failure = Never
    public typealias Body = Never

    @inlinable
    public func parse(_ input: inout Input) {
        var index = input.startIndex
        while index < input.endIndex {
            let byte = input[index]
            guard byte == 0x20 || byte == 0x09 else { break }
            input.formIndex(after: &index)
        }
        input = input[index...]
    }
}

public import Byte_Parser_Primitives
import Parser_Primitives

extension RFC_9110.Parse {

    public struct QuotedString<Input: Collection.Slice.`Protocol`>: Sendable
    where Input: Sendable, Input.Element == Byte {
        @inlinable
        public init() {}
    }
}

extension RFC_9110.Parse.QuotedString: Parser.`Protocol` {
    public typealias Output = [Byte]
    public typealias Failure = RFC_9110.Parse.Error.QuotedString
    public typealias Body = Never

    @inlinable
    public func parse(_ input: inout Input) throws(Failure) -> [Byte] {
        var index = input.startIndex
        guard index < input.endIndex, input[index] == 0x22 else {
            throw .expectedOpenQuote
        }
        input.formIndex(after: &index)

        var result: [Byte] = []

        while index < input.endIndex {
            let byte = input[index]

            if byte == 0x22 {

                input.formIndex(after: &index)
                input = input[index...]
                return result
            }

            if byte == 0x5C {

                input.formIndex(after: &index)
                guard index < input.endIndex else {
                    throw .unexpectedEndOfInput
                }
                let escaped = input[index]

                guard escaped == 0x09 || (escaped >= 0x20 && escaped <= 0x7E) || escaped >= 0x80
                else {
                    throw .invalidEscapeSequence
                }
                result.append(escaped)
                input.formIndex(after: &index)
                continue
            }

            result.append(byte)
            input.formIndex(after: &index)
        }

        throw .unexpectedEndOfInput
    }
}

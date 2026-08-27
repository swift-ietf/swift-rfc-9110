public import Byte_Parser
import Parser

extension RFC_9110.Parse {

    public struct Token<Input: Collection.Slice.`Protocol`>: Sendable
    where Input: Sendable, Input.Element == Byte {
        @inlinable
        public init() {}
    }
}

extension RFC_9110.Parse.Token: Parser.`Protocol` {
    public typealias Output = Input
    public typealias Failure = RFC_9110.Parse.Error.Token
    public typealias Body = Never

    @inlinable
    public func parse(_ input: inout Input) throws(Failure) -> Input {
        var index = input.startIndex

        while index < input.endIndex {
            guard Self.isTchar(input[index]) else { break }
            input.formIndex(after: &index)
        }

        guard index > input.startIndex else {
            throw .expectedToken
        }

        let result = input[input.startIndex..<index]
        input = input[index...]
        return result
    }

    @inlinable
    public static func isTchar(_ byte: Byte) -> Bool {
        switch byte {
        case 0x21, 0x23, 0x24, 0x25, 0x26, 0x27, 0x2A, 0x2B,
            0x2D, 0x2E, 0x5E, 0x5F, 0x60, 0x7C, 0x7E:
            true

        case 0x30...0x39: true

        case 0x41...0x5A: true

        case 0x61...0x7A: true

        default: false
        }
    }
}

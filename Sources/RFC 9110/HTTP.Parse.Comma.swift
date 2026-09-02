public import Byte
public import Checkpoint
public import Cursor
import Iterator
public import Iterator_Protocol
public import Parser

extension RFC_9110.Parse {

    public struct Comma<Input: Cursor.`Protocol`>: Sendable
    where Input.Element == Byte, Input.Failure == Never {
        @inlinable
        public init() {}
    }
}

extension RFC_9110.Parse.Comma: Parser.`Protocol` {
    public typealias Output = Void
    public typealias Failure = RFC_9110.Parse.Error.Comma
    public typealias Body = Never

    @inlinable
    public func parse(_ input: inout Input) throws(Failure) {
        let start = input.checkpoint
        RFC_9110.Parse.OWS<Input>().parse(&input)
        guard let comma = input.next(), comma.bitPattern == 0x2C else {
            input.seek(to: start)
            throw .expectedComma
        }
        RFC_9110.Parse.OWS<Input>().parse(&input)
    }
}

public import Byte
public import Checkpoint
public import Cursor
import Iterator
public import Iterator_Protocol
public import Parser

extension RFC_9110.Parse {

    public struct OWS<Input: Cursor.`Protocol`>: Sendable
    where Input.Element == Byte, Input.Failure == Never {
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
        while true {
            let checkpoint = input.checkpoint
            guard let byte = input.next() else { return }
            guard byte.bitPattern == 0x20 || byte.bitPattern == 0x09 else {
                input.seek(to: checkpoint)
                return
            }
        }
    }
}

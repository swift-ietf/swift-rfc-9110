public import Byte
public import Checkpoint
public import Cursor
import Iterator
public import Iterator_Protocol
public import Parser

extension RFC_9110.Parse {

    public struct QuotedString<Input: Cursor.`Protocol`>: Sendable
    where Input.Element == Byte, Input.Failure == Never {
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
        let start = input.checkpoint
        guard let open = input.next(), open.bitPattern == 0x22 else {
            input.seek(to: start)
            throw .expectedOpenQuote
        }

        var result: [Byte] = []

        while let byte = input.next() {

            if byte.bitPattern == 0x22 {
                return result
            }

            if byte.bitPattern == 0x5C {
                guard let escaped = input.next() else {
                    throw .unexpectedEndOfInput
                }

                guard
                    escaped.bitPattern == 0x09
                        || (escaped.bitPattern >= 0x20 && escaped.bitPattern <= 0x7E)
                        || escaped.bitPattern >= 0x80
                else {
                    throw .invalidEscapeSequence
                }
                result.append(escaped)
                continue
            }

            result.append(byte)
        }

        throw .unexpectedEndOfInput
    }
}

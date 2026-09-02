public import Byte
public import Checkpoint
public import Cursor
public import Iterator
public import Iterator_Protocol
public import Parser

extension RFC_9110.Parse {

    public struct Token<Input: Cursor.`Protocol`>: Sendable
    where Input.Element == Byte, Input.Failure == Never {
        @inlinable
        public init() {}
    }
}

extension RFC_9110.Parse.Token: Parser.`Protocol` {
    public typealias Output = [Byte]
    public typealias Failure = RFC_9110.Parse.Error.Token
    public typealias Body = Never

    @inlinable
    public func parse(_ input: inout Input) throws(Failure) -> [Byte] {
        var result: [Byte] = []

        while true {
            let checkpoint = input.checkpoint
            guard let byte = input.next() else { break }
            guard Self.isTchar(byte) else {
                input.seek(to: checkpoint)
                break
            }
            result.append(byte)
        }

        guard !result.isEmpty else {
            throw .expectedToken
        }

        return result
    }

    @inlinable
    public static func isTchar(_ byte: Byte) -> Bool {
        switch byte.bitPattern {
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

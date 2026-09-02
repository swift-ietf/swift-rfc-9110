public import Byte
public import Byte_Standard_Library_Integration
public import Checkpoint
public import Cursor
public import Iterator
public import Iterator_Protocol
public import Parser

extension RFC_9110.Entity.Tag {

    public struct Parser<Input: Cursor.`Protocol`>: Sendable
    where Input.Element == Byte, Input.Failure == Never {
        @inlinable
        public init() {}
    }
}

extension RFC_9110.Entity.Tag.Parser: Parsing {
    public typealias Output = RFC_9110.Entity.Tag
    public typealias Failure = RFC_9110.Parse.Error.QuotedString
    public typealias Body = Never

    @inlinable
    public func parse(_ input: inout Input) throws(Failure) -> RFC_9110.Entity.Tag {
        RFC_9110.Parse.OWS<Input>().parse(&input)

        var isWeak = false
        let beforeWeak = input.checkpoint
        if let w = input.next(), w.bitPattern == 0x57,
            let slash = input.next(), slash.bitPattern == 0x2F
        {
            isWeak = true
        } else {
            input.seek(to: beforeWeak)
        }

        let bytes = try RFC_9110.Parse.QuotedString<Input>().parse(&input)
        return RFC_9110.Entity.Tag(
            value: String(decoding: bytes, as: UTF8.self),
            isWeak: isWeak
        )
    }
}

public import Byte
public import Byte_Standard_Library_Integration
public import Checkpoint
public import Cursor
import Iterator
public import Iterator_Protocol
public import Parser

extension RFC_9110.Parse {

    public struct Directive<Input: Cursor.`Protocol`>: Sendable
    where Input.Element == Byte, Input.Failure == Never {
        @inlinable
        public init() {}
    }
}

extension RFC_9110.Parse.Directive: Parser.`Protocol` {
    public typealias Output = (name: String, value: String?)
    public typealias Failure = RFC_9110.Parse.Error.Token
    public typealias Body = Never

    @inlinable
    public func parse(_ input: inout Input) throws(Failure) -> (name: String, value: String?) {
        let nameBytes = try RFC_9110.Parse.Token<Input>().parse(&input)
        let name = String(decoding: nameBytes, as: UTF8.self)

        let afterName = input.checkpoint
        RFC_9110.Parse.OWS<Input>().parse(&input)
        guard let equals = input.next(), equals.bitPattern == 0x3D else {
            input.seek(to: afterName)
            return (name: name, value: nil)
        }
        RFC_9110.Parse.OWS<Input>().parse(&input)

        let beforeValue = input.checkpoint

        do throws(RFC_9110.Parse.Error.QuotedString) {
            let quoted = try RFC_9110.Parse.QuotedString<Input>().parse(&input)
            return (name: name, value: String(decoding: quoted, as: UTF8.self))
        } catch {
            input.seek(to: beforeValue)
        }

        do throws(RFC_9110.Parse.Error.Token) {
            let token = try RFC_9110.Parse.Token<Input>().parse(&input)
            return (name: name, value: String(decoding: token, as: UTF8.self))
        } catch {
            input.seek(to: beforeValue)
        }

        return (name: name, value: nil)
    }
}

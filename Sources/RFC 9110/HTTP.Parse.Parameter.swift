public import Byte
public import Checkpoint
public import Cursor
import Iterator
public import Iterator_Protocol
public import Parser

extension RFC_9110.Parse {

    public struct Parameter<Input: Cursor.`Protocol`>: Sendable
    where Input.Element == Byte, Input.Failure == Never {
        @inlinable
        public init() {}
    }
}

extension RFC_9110.Parse.Parameter: Parser.`Protocol` {
    public typealias Output = (name: [Byte], value: [Byte])
    public typealias Failure = RFC_9110.Parse.Error.Parameter
    public typealias Body = Never

    @inlinable
    public func parse(_ input: inout Input) throws(Failure) -> (name: [Byte], value: [Byte]) {

        let name: [Byte]
        do throws(RFC_9110.Parse.Error.Token) {
            name = try RFC_9110.Parse.Token<Input>().parse(&input)
        } catch {
            throw .expectedToken
        }

        let afterName = input.checkpoint
        guard let equals = input.next(), equals.bitPattern == 0x3D else {
            input.seek(to: afterName)
            throw .expectedEquals
        }

        if RFC_9110.Parse.peek(input)?.bitPattern == 0x22 {
            let value: [Byte]
            do throws(RFC_9110.Parse.Error.QuotedString) {
                value = try RFC_9110.Parse.QuotedString<Input>().parse(&input)
            } catch {
                throw .invalidQuotedString(error)
            }
            return (name: name, value: value)
        }

        let value: [Byte]
        do throws(RFC_9110.Parse.Error.Token) {
            value = try RFC_9110.Parse.Token<Input>().parse(&input)
        } catch {
            throw .expectedValue
        }
        return (name: name, value: value)
    }
}

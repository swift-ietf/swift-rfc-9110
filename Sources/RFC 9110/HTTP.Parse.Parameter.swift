public import Byte_Parser
import Parser

extension RFC_9110.Parse {

    public struct Parameter<Input: Collection.Slice.`Protocol`>: Sendable
    where Input: Sendable, Input.Element == Byte {
        @inlinable
        public init() {}
    }
}

extension RFC_9110.Parse.Parameter: Parser.`Protocol` {
    public typealias Output = (name: Input, value: [Byte])
    public typealias Failure = RFC_9110.Parse.Error.Parameter
    public typealias Body = Never

    @inlinable
    public func parse(_ input: inout Input) throws(Failure) -> (name: Input, value: [Byte]) {

        let name: Input
        do throws(RFC_9110.Parse.Error.Token) {
            name = try RFC_9110.Parse.Token<Input>().parse(&input)
        } catch {
            throw .expectedToken
        }

        guard input.startIndex < input.endIndex, input[input.startIndex] == 0x3D else {
            throw .expectedEquals
        }
        input = input[input.index(after: input.startIndex)...]

        if input.startIndex < input.endIndex, input[input.startIndex] == 0x22 {

            let value: [Byte]
            do throws(RFC_9110.Parse.Error.QuotedString) {
                value = try RFC_9110.Parse.QuotedString<Input>().parse(&input)
            } catch {
                throw .invalidQuotedString(error)
            }
            return (name: name, value: value)
        } else {

            let tokenValue: Input
            do throws(RFC_9110.Parse.Error.Token) {
                tokenValue = try RFC_9110.Parse.Token<Input>().parse(&input)
            } catch {
                throw .expectedValue
            }
            var bytes: [Byte] = []
            var i = tokenValue.startIndex
            while i < tokenValue.endIndex {
                bytes.append(tokenValue[i])
                i = tokenValue.index(after: i)
            }
            return (name: name, value: bytes)
        }
    }
}

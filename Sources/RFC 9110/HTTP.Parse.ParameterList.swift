public import Byte
public import Checkpoint
public import Cursor
import Iterator
public import Iterator_Protocol
public import Parser

extension RFC_9110.Parse {

    public struct ParameterList<Input: Cursor.`Protocol`>: Sendable
    where Input.Element == Byte, Input.Failure == Never {
        @inlinable
        public init() {}
    }
}

extension RFC_9110.Parse.ParameterList: Parser.`Protocol` {
    public typealias Output = [(name: [Byte], value: [Byte])]
    public typealias Failure = Never
    public typealias Body = Never

    @inlinable
    public func parse(_ input: inout Input) -> [(name: [Byte], value: [Byte])] {
        var results: [(name: [Byte], value: [Byte])] = []

        while true {

            let saved = input.checkpoint

            RFC_9110.Parse.OWS<Input>().parse(&input)
            guard let semicolon = input.next(), semicolon.bitPattern == 0x3B else {
                input.seek(to: saved)
                break
            }
            RFC_9110.Parse.OWS<Input>().parse(&input)

            let param: (name: [Byte], value: [Byte])
            do throws(RFC_9110.Parse.Error.Parameter) {
                param = try RFC_9110.Parse.Parameter<Input>().parse(&input)
            } catch {
                input.seek(to: saved)
                break
            }
            results.append(param)
        }

        return results
    }
}

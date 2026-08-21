public import Byte_Parser_Primitives
import Parser_Primitives

extension RFC_9110.Parse {

    public struct ParameterList<Input: Collection.Slice.`Protocol`>: Sendable
    where Input: Sendable, Input.Element == Byte {
        @inlinable
        public init() {}
    }
}

extension RFC_9110.Parse.ParameterList: Parser.`Protocol` {
    public typealias Output = [(name: Input, value: [Byte])]
    public typealias Failure = Never
    public typealias Body = Never

    @inlinable
    public func parse(_ input: inout Input) -> [(name: Input, value: [Byte])] {
        var results: [(name: Input, value: [Byte])] = []

        while true {

            let saved = input

            RFC_9110.Parse.OWS<Input>().parse(&input)
            guard input.startIndex < input.endIndex, input[input.startIndex] == 0x3B else {
                input = saved
                break
            }
            input = input[input.index(after: input.startIndex)...]
            RFC_9110.Parse.OWS<Input>().parse(&input)

            let param: (name: Input, value: [Byte])
            do throws(RFC_9110.Parse.Error.Parameter) {
                param = try RFC_9110.Parse.Parameter<Input>().parse(&input)
            } catch {
                input = saved
                break
            }
            results.append(param)
        }

        return results
    }
}

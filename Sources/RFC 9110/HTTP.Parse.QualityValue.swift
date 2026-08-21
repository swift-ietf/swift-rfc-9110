public import ASCII_Decimal_Parser_Primitives
import Byte_Parser_Primitives
import Parser_Primitives

extension RFC_9110.Parse {

    public struct QualityValue<Input: Collection.Slice.`Protocol`>: Sendable
    where Input: Sendable, Input.Element == Byte {
        @inlinable
        public init() {}
    }
}

extension RFC_9110.Parse.QualityValue: Parser.`Protocol` {
    public typealias Output = Int
    public typealias Failure = RFC_9110.Parse.Error.QualityValue
    public typealias Body = Never

    @inlinable
    public func parse(_ input: inout Input) throws(Failure) -> Int {

        guard input.startIndex < input.endIndex else { throw .invalidQValue }
        let intPart = input[input.startIndex]
        guard intPart == 0x30 || intPart == 0x31 else { throw .invalidQValue }
        input = input[input.index(after: input.startIndex)...]

        if input.startIndex < input.endIndex, input[input.startIndex] == 0x2E {
            input = input[input.index(after: input.startIndex)...]

            var frac = 0
            var digits = 0
            while digits < 3 {
                let digit: Int
                do throws(ASCII.Decimal.Error) {
                    digit = try ASCII.Decimal.Parser<Input, Int>(sign: .none, count: .exactly(1))
                        .parse(&input)
                } catch {
                    break
                }
                frac = frac * 10 + digit
                digits += 1
            }

            while digits < 3 {
                frac *= 10
                digits += 1
            }

            if intPart == 0x31 {

                guard frac == 0 else { throw .invalidQValue }
                return 1000
            }
            return frac
        }

        return intPart == 0x31 ? 1000 : 0
    }
}

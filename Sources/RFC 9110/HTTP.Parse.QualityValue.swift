public import ASCII_Decimal_Parser
public import Byte
public import Checkpoint
public import Cursor
public import Iterator
public import Iterator_Protocol
public import Parser

extension RFC_9110.Parse {

    public struct QualityValue<Input: Cursor.`Protocol`>: Sendable
    where Input.Element == Byte, Input.Failure == Never {
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
        let start = input.checkpoint

        guard let leading = input.next() else {
            input.seek(to: start)
            throw .invalidQValue
        }
        let intPart = leading.bitPattern
        guard intPart == 0x30 || intPart == 0x31 else {
            input.seek(to: start)
            throw .invalidQValue
        }

        let afterInteger = input.checkpoint
        guard let point = input.next(), point.bitPattern == 0x2E else {
            input.seek(to: afterInteger)
            return intPart == 0x31 ? 1000 : 0
        }

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
}

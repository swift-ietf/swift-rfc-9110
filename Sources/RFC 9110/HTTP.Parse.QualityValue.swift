//
//  HTTP.Parse.QualityValue.swift
//  swift-rfc-9110
//
//  Quality value weight: OWS ";" OWS "q=" qvalue
//

public import Byte_Parser_Primitives
public import Parser_Primitives
public import ASCII_Decimal_Parser_Primitives

extension RFC_9110.Parse {
    /// Parses an HTTP quality value (weight) per RFC 9110 Section 12.4.2.
    ///
    /// `weight = OWS ";" OWS "q=" qvalue`
    /// `qvalue = ( "0" [ "." *3DIGIT ] ) / ( "1" [ "." *3"0" ] )`
    ///
    /// Returns a value between 0 and 1000 (q=1.000 -> 1000, q=0.5 -> 500).
    /// Using integer representation avoids floating-point imprecision.
    public struct QualityValue<Input: Collection.Slice.`Protocol`>: Sendable
    where Input: Sendable, Input.Element == Byte {
        @inlinable
        public init() {}
    }
}

extension RFC_9110.Parse.QualityValue: Parser.`Protocol` {
    public typealias Output = Int
    public typealias Failure = RFC_9110.Parse.QualityValue<Input>.Error

    @inlinable
    public func parse(_ input: inout Input) throws(Failure) -> Int {
        // OWS ";" OWS
        RFC_9110.Parse.OWS<Input>().parse(&input)
        guard input.startIndex < input.endIndex, input[input.startIndex] == 0x3B else {
            throw .expectedSemicolon
        }
        input = input[input.index(after: input.startIndex)...]
        RFC_9110.Parse.OWS<Input>().parse(&input)

        // "q=" (case-insensitive for q)
        guard input.startIndex < input.endIndex else { throw .expectedQ }
        let q = input[input.startIndex]
        guard q == 0x71 || q == 0x51 else { throw .expectedQ } // 'q' or 'Q'
        input = input[input.index(after: input.startIndex)...]

        guard input.startIndex < input.endIndex, input[input.startIndex] == 0x3D else {
            throw .expectedQ
        }
        input = input[input.index(after: input.startIndex)...]

        // qvalue: digit before decimal
        guard input.startIndex < input.endIndex else { throw .invalidQValue }
        let intPart = input[input.startIndex]
        guard intPart == 0x30 || intPart == 0x31 else { throw .invalidQValue } // '0' or '1'
        input = input[input.index(after: input.startIndex)...]

        // Optional decimal part
        if input.startIndex < input.endIndex, input[input.startIndex] == 0x2E {
            input = input[input.index(after: input.startIndex)...]

            // Accumulate up to 3 fractional ASCII digits, delegating the
            // per-digit ASCII classification + conversion to the L1 decimal
            // parser. Each `.exactly(1)` parse consumes exactly one digit byte
            // and advances `input`; when the next byte is absent or non-digit
            // it throws (leaving `input` unchanged), which ends the loop —
            // byte-for-byte the historical `guard isDigit else break` behavior.
            // Zero fractional digits ("0.") is therefore permitted (frac = 0).
            var frac = 0
            var digits = 0
            while digits < 3 {
                let digit: Int
                do {
                    digit = try ASCII.Decimal.Parser<Input, Int>(sign: .none, count: .exactly(1))
                        .parse(&input)
                } catch {
                    break
                }
                frac = frac * 10 + digit
                digits += 1
            }

            // Pad to 3 digits: "0.5" -> 500, "0.05" -> 50
            while digits < 3 {
                frac *= 10
                digits += 1
            }

            if intPart == 0x31 {
                // q=1.xxx — only 1.000 is valid
                guard frac == 0 else { throw .invalidQValue }
                return 1000
            }
            return frac
        }

        return intPart == 0x31 ? 1000 : 0
    }
}

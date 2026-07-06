//
//  HTTP.Parse.ParameterList.swift
//  swift-rfc-9110
//
//  Semicolon-separated parameter list: *( OWS ";" OWS parameter )
//

public import Byte_Parser_Primitives
public import Parser_Primitives

extension RFC_9110.Parse {
    /// Parses a semicolon-separated list of parameters.
    ///
    /// `*( OWS ";" OWS parameter )`
    ///
    /// Used by media-type, content-type, and content-disposition headers.
    public struct ParameterList<Input: Collection.Slice.`Protocol`>: Sendable
    where Input: Sendable, Input.Element == Byte {
        @inlinable
        public init() {}
    }
}

extension RFC_9110.Parse.ParameterList: Parser.`Protocol` {
    public typealias Output = [(name: Input, value: [Byte])]
    public typealias Failure = Never

    @inlinable
    public func parse(_ input: inout Input) -> [(name: Input, value: [Byte])] {
        var results: [(name: Input, value: [Byte])] = []

        while true {
            // Save position before attempting separator + parameter
            let saved = input

            // OWS ";" OWS
            RFC_9110.Parse.OWS<Input>().parse(&input)
            guard input.startIndex < input.endIndex, input[input.startIndex] == 0x3B else {
                input = saved
                break
            }
            input = input[input.index(after: input.startIndex)...]
            RFC_9110.Parse.OWS<Input>().parse(&input)

            // parameter
            guard let param = try? RFC_9110.Parse.Parameter<Input>().parse(&input) else {
                input = saved
                break
            }
            results.append(param)
        }

        return results
    }
}

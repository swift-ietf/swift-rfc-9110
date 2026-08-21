public import Byte_Parser_Primitives
public import Byte_Primitives_Standard_Library_Integration
public import Parser_Primitives

extension RFC_9110.MediaType {

    public struct Parser<Input: Collection.Slice.`Protocol` & Swift.Collection>: Sendable
    where Input: Sendable, Input.Element == Byte {
        @inlinable
        public init() {}
    }
}

extension RFC_9110.MediaType.Parser: Parser_Primitives.Parser.`Protocol` {
    public typealias Output = RFC_9110.MediaType
    public typealias Failure = RFC_9110.Parse.Error.MediaType
    public typealias Body = Never

    @inlinable
    public func parse(_ input: inout Input) throws(Failure) -> RFC_9110.MediaType {

        RFC_9110.Parse.OWS<Input>().parse(&input)

        let typeSlice: Input
        do throws(RFC_9110.Parse.Error.Token) {
            typeSlice = try RFC_9110.Parse.Token<Input>().parse(&input)
        } catch {
            throw .expectedType
        }

        guard input.startIndex < input.endIndex,
            input[input.startIndex] == 0x2F
        else { throw .expectedSlash }
        input = input[input.index(after: input.startIndex)...]

        let subtypeSlice: Input
        do throws(RFC_9110.Parse.Error.Token) {
            subtypeSlice = try RFC_9110.Parse.Token<Input>().parse(&input)
        } catch {
            throw .expectedSubtype
        }

        let params = RFC_9110.Parse.ParameterList<Input>().parse(&input)

        let type = String(decoding: typeSlice, as: UTF8.self).lowercased()
        let subtype = String(decoding: subtypeSlice, as: UTF8.self).lowercased()
        var parameters: [String: String] = [:]
        for p in params {
            let name = String(decoding: p.name, as: UTF8.self).lowercased()
            let value = String(decoding: p.value, as: UTF8.self)
            parameters[name] = value
        }
        return RFC_9110.MediaType(type, subtype, parameters: parameters)
    }
}

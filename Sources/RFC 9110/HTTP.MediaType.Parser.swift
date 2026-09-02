public import Byte
public import Byte_Standard_Library_Integration
public import Checkpoint
public import Cursor
public import Iterator
public import Iterator_Protocol
public import Parser

extension RFC_9110.MediaType {

    public struct Parser<Input: Cursor.`Protocol`>: Sendable
    where Input.Element == Byte, Input.Failure == Never {
        @inlinable
        public init() {}
    }
}

extension RFC_9110.MediaType.Parser: Parsing {
    public typealias Output = RFC_9110.MediaType
    public typealias Failure = RFC_9110.Parse.Error.MediaType
    public typealias Body = Never

    @inlinable
    public func parse(_ input: inout Input) throws(Failure) -> RFC_9110.MediaType {

        RFC_9110.Parse.OWS<Input>().parse(&input)

        let typeBytes: [Byte]
        do throws(RFC_9110.Parse.Error.Token) {
            typeBytes = try RFC_9110.Parse.Token<Input>().parse(&input)
        } catch {
            throw .expectedType
        }

        let afterType = input.checkpoint
        guard let slash = input.next(), slash.bitPattern == 0x2F else {
            input.seek(to: afterType)
            throw .expectedSlash
        }

        let subtypeBytes: [Byte]
        do throws(RFC_9110.Parse.Error.Token) {
            subtypeBytes = try RFC_9110.Parse.Token<Input>().parse(&input)
        } catch {
            throw .expectedSubtype
        }

        let params = RFC_9110.Parse.ParameterList<Input>().parse(&input)

        let type = String(decoding: typeBytes, as: UTF8.self).lowercased()
        let subtype = String(decoding: subtypeBytes, as: UTF8.self).lowercased()
        var parameters: [String: String] = [:]
        for p in params {
            let name = String(decoding: p.name, as: UTF8.self).lowercased()
            let value = String(decoding: p.value, as: UTF8.self)
            parameters[name] = value
        }
        return RFC_9110.MediaType(type, subtype, parameters: parameters)
    }
}

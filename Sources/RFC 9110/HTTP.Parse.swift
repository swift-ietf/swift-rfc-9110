public import Byte
import Byte_Parser
import Byte_Standard_Library_Integration
import Checkpoint
public import Cursor
import Iterator
public import Iterator_Protocol
import Parser

extension RFC_9110 {

    public enum Parse {}
}

extension RFC_9110.Parse {

    public enum Error {}
}

extension RFC_9110.Parse {

    @usableFromInline
    static func peek<Input: Cursor.`Protocol`>(_ input: Input) -> Byte?
    where Input.Element == Byte, Input.Failure == Never {
        var copy = input
        return copy.next()
    }
}

extension RFC_9110.Parse {

    public static func tokens(in headerValue: String) -> [String] {
        var input = Byte.Input(utf8: headerValue)
        let tokens = CommaSeparated(Token<Byte.Input>()).parse(&input)
        return tokens.map { String(decoding: $0, as: UTF8.self) }
    }

    public static func directives(in headerValue: String) -> [(name: String, value: String?)] {
        var input = Byte.Input(utf8: headerValue)
        return CommaSeparated(Directive<Byte.Input>()).parse(&input)
    }
}

public import Byte
public import Byte_Parser
public import Checkpoint
public import Cursor
public import Cursor_Parser_Many
public import Cursor_Parser_Optionally
import Iterator
public import Iterator_Protocol
public import Parser

extension RFC_9110.Parse {

    public struct CommaSeparated<Element: Parser.`Protocol`>
    where
        Element.Input: Cursor.`Protocol`,
        Element.Input: Copyable & Escapable,
        Element.Input.Element == Byte,
        Element.Input.Failure == Never,
        Element.Input.Checkpoint: Equatable,
        Element.Output: Copyable & Escapable
    {
        public let element: Element

        @inlinable
        public init(_ element: Element) {
            self.element = element
        }

        @inlinable
        public init(@Parser.Builder<Element.Input> _ element: () -> Element) {
            self.element = element()
        }
    }
}

extension RFC_9110.Parse.CommaSeparated: Parser.`Protocol` {
    public typealias Input = Element.Input
    public typealias Output = [Element.Output]
    public typealias Failure = Never
    public typealias Body = Never

    @inlinable
    public func parse(_ input: inout Input) -> [Element.Output] {
        RFC_9110.Parse.OWS<Input>().parse(&input)

        let separated = Parser.Many<Input, Parser.Optionally<Element>>
            .Separated<RFC_9110.Parse.Comma<Input>>(
                element: { Parser.Optionally(self.element) },
                separator: { RFC_9110.Parse.Comma<Input>() }
            )

        guard let elements = try? separated.parse(&input) else { return [] }
        return elements.compactMap { $0 }
    }
}

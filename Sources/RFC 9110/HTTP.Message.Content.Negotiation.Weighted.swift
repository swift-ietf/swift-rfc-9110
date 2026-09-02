public import Byte
public import Checkpoint
public import Cursor
public import Either
public import Iterator
public import Iterator_Protocol
public import Parser

extension RFC_9110.Message.Content.Negotiation {

    package struct Weighted<Element: Parsing>
    where
        Element.Input: Cursor.`Protocol`,
        Element.Input: Copyable & Escapable,
        Element.Input.Element == Byte,
        Element.Input.Failure == Never,
        Element.Output: Copyable & Escapable
    {
        package let element: Element

        @inlinable
        package init(_ element: Element) {
            self.element = element
        }
    }
}

extension RFC_9110.Message.Content.Negotiation.Weighted: Parsing {
    package typealias Input = Element.Input
    package typealias Output = (
        value: Element.Output,
        quality: RFC_9110.Message.Content.Negotiation.QualityValue
    )
    package typealias Failure = Either<Element.Failure, RFC_9110.Parse.Error.QualityValue>
    package typealias Body = Never

    @inlinable
    package func parse(_ input: inout Input) throws(Failure) -> Output {
        let value: Element.Output
        do throws(Element.Failure) {
            value = try element.parse(&input)
        } catch {
            throw .left(error)
        }

        switch RFC_9110.Message.Content.Negotiation.Weight.parse(&input) {
        case .absent:
            return (value: value, quality: .default)

        case .value(let quality):
            return (value: value, quality: quality)

        case .invalid:
            throw .right(.invalidQValue)
        }
    }
}

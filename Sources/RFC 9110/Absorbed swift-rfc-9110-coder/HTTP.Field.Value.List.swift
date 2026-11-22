#if Coder
    public import Byte
    public import Coder
    public import Cursor
    import Either
    import Parser
    import Serializer

    extension IETF.RFC.`9110`.Field.Value {

        public struct List<Element: Coding>: Coding
        where
            Element.Input: Cursor.`Protocol`<Byte, Never> & Copyable & Escapable,
            Element.Buffer: RangeReplaceableCollection<Byte>,
            Element.Output: Copyable & Escapable
        {

            public typealias Input = Element.Input

            public typealias Buffer = Element.Buffer

            public typealias Output = [Element.Output]

            public typealias Failure = Error

            public let element: Element
            public let rejected: (Element.Failure) -> Bool

            public init(_ element: Element, rejected: @escaping (Element.Failure) -> Bool = { _ in false }) {
                self.element = element
                self.rejected = rejected
            }

            public borrowing func parse(_ input: inout Input) throws(Failure) -> Output {
                IETF.RFC.`9110`.OWS.Coder<Input, Buffer>().parse(&input)

                let mark = input.checkpoint
                do throws(IETF.RFC.`9110`.Field.Value.Delimiter.Error) {
                    try IETF.RFC.`9110`.Field.Value.Delimiter.Coder<Input, Buffer>().parse(&input)
                } catch {
                    input.seek(to: mark)
                }

                let probe = input.checkpoint
                let hasElement = input.next() != nil
                input.seek(to: probe)
                if !hasElement { return [] }

                do throws(Parser::Many<Input, Element>.Separated<IETF.RFC.`9110`.Field.Value.Delimiter.Coder<Input, Buffer>>.Error) {
                    return try Parser::Many.Separated(
                        element,
                        separator: IETF.RFC.`9110`.Field.Value.Delimiter.Coder<Input, Buffer>(),
                        rejected: rejected,
                        separatorRejected: {
                            if case .expectedComma = $0 { return true }
                            return false
                        }
                    )
                    .parse(&input)
                } catch {
                    throw Self.error(error)
                }
            }

            public borrowing func serialize(_ output: Output, into buffer: inout Buffer) throws(Failure) {
                do throws(Parser::Many<Input, Element>.Separated<IETF.RFC.`9110`.Field.Value.Delimiter.Coder<Input, Buffer>>.Error) {
                    try Parser::Many.Separated(
                        element,
                        separator: IETF.RFC.`9110`.Field.Value.Delimiter.Coder<Input, Buffer>(),
                        rejected: rejected,
                        separatorRejected: {
                            if case .expectedComma = $0 { return true }
                            return false
                        }
                    )
                    .serialize(output, into: &buffer)
                } catch {
                    throw Self.error(error)
                }
            }

            static func error(
                _ failure: Parser::Many<Input, Element>.Separated<IETF.RFC.`9110`.Field.Value.Delimiter.Coder<Input, Buffer>>.Error
            ) -> Failure {
                switch failure {
                case .element(let error): .element(error)
                default: .delimiter
                }
            }
        }
    }

    extension IETF.RFC.`9110`.Field.Value.List {

        public enum Error: Swift::Error {
            case element(Element.Failure)
            case delimiter
        }
    }

    extension IETF.RFC.`9110`.Field.Value.List.Error: Equatable where Element.Failure: Equatable {}

    extension IETF.RFC.`9110`.Field.Value {

        public enum Delimiter {}
    }

    extension IETF.RFC.`9110`.Field.Value.Delimiter {

        public struct Coder<Input: Cursor.`Protocol`<Byte, Never>, Buffer: RangeReplaceableCollection<Byte>>: Coding {

            public typealias Output = Void

            public typealias Failure = Error

            public let canonical: [Byte]

            public init(canonical: [Byte] = [Byte(bitPattern: 0x2C), Byte(bitPattern: 0x20)]) {
                self.canonical = canonical
            }

            public borrowing func parse(_ input: inout Input) throws(Failure) {
                var commas = 0
                while true {
                    let mark = input.checkpoint
                    _ = IETF.RFC.`9110`.Whitespace.skip(&input)
                    guard let byte = input.next(), byte.bitPattern == 0x2C else {
                        input.seek(to: mark)
                        break
                    }
                    commas += 1
                }
                guard commas > 0 else { throw .expectedComma }
                _ = IETF.RFC.`9110`.Whitespace.skip(&input)
            }

            public borrowing func serialize(_ output: Void, into buffer: inout Buffer) throws(Failure) {
                buffer.append(contentsOf: canonical)
            }
        }

        public enum Error: Swift::Error, Equatable {
            case expectedComma
        }
    }

    extension IETF.RFC.`9110`.Field.Value {

        public static func tokens(in headerValue: String) -> [String] {
            var input = [Byte](utf8: headerValue)[...]
            let tokens = (try? List(IETF.RFC.`9110`.Token.coder, rejected: { $0 == .empty }).parse(&input)) ?? []
            return tokens.map { $0.rawValue }
        }

        public static func directives(in headerValue: String) -> [(name: String, value: String?)] {
            var input = [Byte](utf8: headerValue)[...]
            return (try? List(IETF.RFC.`9110`.Field.Value.Directive.Coder<ArraySlice<Byte>, [Byte]>()).parse(&input)) ?? []
        }
    }

    extension IETF.RFC.`9110`.Field.Value {

        enum Directive {}
    }

    extension IETF.RFC.`9110`.Field.Value.Directive {

        struct Coder<Input: Cursor.`Protocol`<Byte, Never>, Buffer: RangeReplaceableCollection<Byte>>: Coding {

            typealias Output = (name: String, value: String?)

            typealias Failure = IETF.RFC.`9110`.Token.Error

            borrowing func parse(_ input: inout Input) throws(Failure) -> Output {
                let name = try IETF.RFC.`9110`.Token.Coder<Input, Buffer>().parse(&input)

                let mark = input.checkpoint
                IETF.RFC.`9110`.OWS.Coder<Input, Buffer>().parse(&input)
                guard let equals = input.next(), equals.bitPattern == 0x3D else {
                    input.seek(to: mark)
                    return (name: name.rawValue, value: nil)
                }
                IETF.RFC.`9110`.OWS.Coder<Input, Buffer>().parse(&input)

                let beforeValue = input.checkpoint
                if let quoted = try? IETF.RFC.`9110`.QuotedString.Coder<Input, Buffer>().parse(&input) {
                    return (name: name.rawValue, value: quoted)
                }
                input.seek(to: beforeValue)
                if let token = try? IETF.RFC.`9110`.Token.Coder<Input, Buffer>().parse(&input) {
                    return (name: name.rawValue, value: token.rawValue)
                }
                input.seek(to: mark)
                return (name: name.rawValue, value: nil)
            }

            borrowing func serialize(_ output: Output, into buffer: inout Buffer) throws(Failure) {
                try IETF.RFC.`9110`.Token.Coder<Input, Buffer>().serialize(IETF.RFC.`9110`.Token(unchecked: output.name), into: &buffer)
                guard let value = output.value else { return }
                buffer.append(Byte(bitPattern: 0x3D))
                do throws(IETF.RFC.`9110`.Token.Error) {
                    try IETF.RFC.`9110`.Token.Coder<Input, Buffer>().serialize(IETF.RFC.`9110`.Token(unchecked: value), into: &buffer)
                } catch {
                    try? IETF.RFC.`9110`.QuotedString.Coder<Input, Buffer>().serialize(value, into: &buffer)
                }
            }
        }
    }
#endif

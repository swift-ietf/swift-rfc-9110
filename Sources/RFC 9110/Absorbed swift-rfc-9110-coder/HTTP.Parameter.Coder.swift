#if Coder
    public import Byte
    public import Coder
    public import Cursor
    import Either
    import Pair
    import Parser
    import Product
    import Serializer

    extension IETF.RFC.`9110`.Parameter {
        public struct Coder<Input: Cursor.`Protocol`<Byte, Never>, Buffer: RangeReplaceableCollection<Byte>>: Coding {
            public init() {}
        }

        public static var coder: Coder<ArraySlice<Byte>, [Byte]> { .init() }

        public enum Error: Swift::Error, Equatable {
            case expectedPrefix
            case expectedName(IETF.RFC.`9110`.Token.Error)
            case invalidTokenValue(IETF.RFC.`9110`.Token.Error)
            case expectedEquals
            case invalidValue(IETF.RFC.`9110`.QuotedString.Error)
        }
    }

    extension IETF.RFC.`9110`.Parameter.Coder {
        public typealias Failure = IETF.RFC.`9110`.Parameter.Error

        @Coder::Builder<Input, Buffer>
        public var body:
            some Coding
                & Parsing<Input, IETF.RFC.`9110`.Parameter, Failure>
                & Serializing<IETF.RFC.`9110`.Parameter, Buffer, Failure>
        {
            Coder::Coder(Input.self, Buffer.self) {
                IETF.RFC.`9110`.Token.Coder()
                Coder::ConsumingLiteral<Input, Buffer>([Byte](utf8: "="))
                Parser::OneOf.Two(
                    IETF.RFC.`9110`.Token.Coder().map(to: \.rawValue, from: { IETF.RFC.`9110`.Token(unchecked: $0) }),
                    IETF.RFC.`9110`.QuotedString.Coder(),
                    rejectFirst: {
                        if case .empty = $0 { return true }
                        return false
                    },
                    rejectSecond: {
                        if case .expectedOpenQuote = $0 { return true }
                        return false
                    },
                    serializationRejectFirst: { failure in
                        switch failure {
                        case .empty, .invalidCharacter: true
                        }
                    }
                )
            }
            .map(
                to: { output in IETF.RFC.`9110`.Parameter(name: output.first, value: output.second) },
                from: { .init($0.name, $0.value) }
            )
            .mapFailure { (failure) -> Failure in
                switch failure {
                case .left(.left(let error)): .expectedName(error)
                case .left(.right): .expectedEquals
                case .right(.first(let error)): .invalidTokenValue(error)
                case .right(.second(let error)): .invalidValue(error)
                case .right(.rejected(_, let error)): .invalidValue(error)
                }
            }
        }
    }

    extension IETF.RFC.`9110`.Parameter {
        public struct Prefixed<Input: Cursor.`Protocol`<Byte, Never>, Buffer: RangeReplaceableCollection<Byte>>: Coding {
            public init() {}
        }
    }

    extension IETF.RFC.`9110`.Parameter.Prefixed {
        public typealias Failure = IETF.RFC.`9110`.Parameter.Error

        @Coder::Builder<Input, Buffer>
        public var body:
            some Coding
                & Parsing<Input, IETF.RFC.`9110`.Parameter, Failure>
                & Serializing<IETF.RFC.`9110`.Parameter, Buffer, Failure>
        {
            Coder::Coder(Input.self, Buffer.self) {
                IETF.RFC.`9110`.OWS.Coder()
                Coder::ConsumingLiteral<Input, Buffer>([Byte](utf8: ";"))
                IETF.RFC.`9110`.OWS.Coder(canonical: " ")
                IETF.RFC.`9110`.Parameter.Coder()
            }
            .mapFailure { (failure) -> Failure in
                switch failure {
                case .right(let error): error
                default: .expectedPrefix
                }
            }
        }
    }

    extension [IETF.RFC.`9110`.Parameter] {
        static func sorted(_ parameters: [String: String]) -> Self {
            parameters.sorted { $0.key < $1.key }.map {
                IETF.RFC.`9110`.Parameter(name: IETF.RFC.`9110`.Token(unchecked: $0.key), value: $0.value)
            }
        }

        var dictionary: [String: String] {
            var result: [String: String] = [:]
            for parameter in self {
                result[parameter.name.rawValue] = parameter.value
            }
            return result
        }
    }
#endif

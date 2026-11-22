#if Coder
    public import Byte
    public import Coder
    public import Cursor
    import Either
    import Pair
    import Parser
    import Serializer

    extension IETF.RFC.`9110`.Representation.Validator.EntityTag {
        public struct Coder<Input: Cursor.`Protocol`<Byte, Never>, Buffer: RangeReplaceableCollection<Byte>>: Coding {
            public init() {}
        }

        public static var coder: Coder<ArraySlice<Byte>, [Byte]> { .init() }

        public enum Error: Swift::Error, Equatable {
            case expectedOpaqueTag(IETF.RFC.`9110`.QuotedString.Error)
        }
    }

    extension IETF.RFC.`9110`.Representation.Validator.EntityTag.Coder {
        public typealias Failure = IETF.RFC.`9110`.Representation.Validator.EntityTag.Error

        @Coder::Builder<Input, Buffer>
        public var body:
            some Coding
                & Parsing<Input, IETF.RFC.`9110`.Representation.Validator.EntityTag, Failure>
                & Serializing<IETF.RFC.`9110`.Representation.Validator.EntityTag, Buffer, Failure>
        {
            Coder::Coder(Input.self, Buffer.self) {
                IETF.RFC.`9110`.OWS.Coder()
                Parser::Optionally(Coder::ConsumingLiteral<Input, Buffer>([Byte](utf8: "W/")), rejected: { _ in true })
                IETF.RFC.`9110`.QuotedString.Coder()
            }
            .map(
                to: { output in IETF.RFC.`9110`.Representation.Validator.EntityTag(value: output.second, isWeak: output.first != nil) },
                from: { .init($0.isWeak ? Optional(()) : nil, $0.value) }
            )
            .mapFailure { (failure) -> Failure in
                switch failure {
                case .left: .expectedOpaqueTag(.expectedOpenQuote)
                case .right(let error): .expectedOpaqueTag(error)
                }
            }
        }
    }

    extension IETF.RFC.`9110`.Representation.Validator.EntityTag {
        public static func parse(_ headerValue: String) -> Self? {
            var input = [Byte](utf8: headerValue)[...]
            do throws(Error) {
                return try coder.parse(&input)
            } catch {
                return nil
            }
        }
    }

    extension IETF.RFC.`9110`.Representation.Validator.EntityTag: LosslessStringConvertible {
        public init?(_ description: String) {
            guard let parsed = Self.parse(description) else { return nil }
            self = parsed
        }
    }

    extension IETF.RFC.`9110`.Representation.Validator.EntityTag: Encodable, Decodable {
        public init(from decoder: any Decoder) throws {
            let container = try decoder.singleValueContainer()
            let string = try container.decode(String.self)

            guard let entityTag = Self.parse(string) else {
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Invalid entity tag: \(string)"
                )
            }

            self = entityTag
        }

        public func encode(to encoder: any Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(headerValue)
        }
    }
#endif

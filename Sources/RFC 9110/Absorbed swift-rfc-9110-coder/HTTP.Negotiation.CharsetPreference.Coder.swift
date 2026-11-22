#if Coder
    public import Byte
    public import Coder
    public import Cursor
    import Parser
    import Serializer

    extension IETF.RFC.`9110`.Negotiation.CharsetPreference {
        public struct Coder<Input: Cursor.`Protocol`<Byte, Never>, Buffer: RangeReplaceableCollection<Byte>>: Coding {
            public init() {}
        }

        public static var coder: Coder<ArraySlice<Byte>, [Byte]> { .init() }
    }

    extension IETF.RFC.`9110`.Negotiation.CharsetPreference.Coder {
        public typealias Failure = IETF.RFC.`9110`.Negotiation.Weighted<IETF.RFC.`9110`.Token.Coder<Input, Buffer>>.Error

        public var body:
            some Coding
                & Parsing<Input, IETF.RFC.`9110`.Negotiation.CharsetPreference, Failure>
                & Serializing<IETF.RFC.`9110`.Negotiation.CharsetPreference, Buffer, Failure>
        {
            return IETF.RFC.`9110`.Negotiation.Weighted(IETF.RFC.`9110`.Token.Coder<Input, Buffer>())
                .map(
                    to: { IETF.RFC.`9110`.Negotiation.CharsetPreference(charset: $0.value.rawValue, quality: $0.quality) },
                    from: { (value: IETF.RFC.`9110`.Token(unchecked: $0.charset), quality: $0.quality) }
                )
        }
    }

    extension IETF.RFC.`9110`.Negotiation.CharsetPreference {
        public static func parse(_ headerValue: String) -> [Self] {
            var input = [Byte](utf8: headerValue)[...]
            let preferences = (try? IETF.RFC.`9110`.Field.Value.List(coder).parse(&input)) ?? []
            return preferences.sorted { $0.quality > $1.quality }
        }
    }
#endif

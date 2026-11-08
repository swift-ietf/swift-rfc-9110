#if Coder
    public import Byte
    public import Coder
    public import Cursor
    import Parser
    import Serializer

    extension RFC_9110.Negotiation.EncodingPreference {
        public struct Coder<
            Input: Cursor.`Protocol`<Byte, Never>,
            Buffer: RangeReplaceableCollection<Byte>
        >: Coding {
            public init() {}
        }

        public static var coder: Coder<ArraySlice<Byte>, [Byte]> { .init() }
    }

    extension RFC_9110.Negotiation.EncodingPreference.Coder {
        public typealias Failure = RFC_9110.Negotiation.Weighted<RFC_9110.Token.Coder<Input, Buffer>>.Error

        public var body:
            some Coding
                & Parsing<Input, RFC_9110.Negotiation.EncodingPreference, Failure>
                & Serializing<RFC_9110.Negotiation.EncodingPreference, Buffer, Failure>
        {
            return RFC_9110.Negotiation.Weighted(RFC_9110.Token.Coder<Input, Buffer>())
                .map(
                    to: {
                        RFC_9110.Negotiation.EncodingPreference(
                            encoding: RFC_9110.Representation.Encoding($0.value.rawValue),
                            quality: $0.quality
                        )
                    },
                    from: { (value: RFC_9110.Token(unchecked: $0.encoding.value), quality: $0.quality) }
                )
        }
    }

    extension RFC_9110.Negotiation.EncodingPreference {
        public static func parse(_ headerValue: String) -> [Self] {
            var input = [Byte](utf8: headerValue)[...]
            let preferences = (try? RFC_9110.Field.Value.List(coder).parse(&input)) ?? []
            return preferences.sorted { $0.quality > $1.quality }
        }
    }
#endif

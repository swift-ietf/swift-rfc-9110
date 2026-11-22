#if Coder
    public import Byte
    public import Coder
    public import Cursor
    import Either
    import Pair
    import Parser
    import Serializer

    extension IETF.RFC.`9110`.Authentication.Challenge {
        public struct Coder<Input: Cursor.`Protocol`<Byte, Never>, Buffer: RangeReplaceableCollection<Byte>>: Coding {
            public init() {}
        }

        public static var coder: Coder<ArraySlice<Byte>, [Byte]> { .init() }

        public enum Error: Swift::Error, Equatable {
            case expectedScheme(IETF.RFC.`9110`.Token.Error)
            case expectedParameters
            case invalidParameter(IETF.RFC.`9110`.Parameter.Error)
        }
    }

    extension IETF.RFC.`9110`.Authentication.Challenge.Coder {
        public typealias Failure = IETF.RFC.`9110`.Authentication.Challenge.Error

        @Coder::Builder<Input, Buffer>
        public var body:
            some Coding
                & Parsing<Input, IETF.RFC.`9110`.Authentication.Challenge, Failure>
                & Serializing<IETF.RFC.`9110`.Authentication.Challenge, Buffer, Failure>
        {
            Coder::Coder(Input.self, Buffer.self) {
                IETF.RFC.`9110`.OWS.Coder()
                IETF.RFC.`9110`.Token.Coder()
                Parser::Many(
                    0...1,
                    Coder::Coder(Input.self, Buffer.self) {
                        IETF.RFC.`9110`.RWS.Coder()
                        IETF.RFC.`9110`.Field.Value.List(IETF.RFC.`9110`.Parameter.Coder())
                    },
                    rejected: {
                        if case .left = $0 { return true }
                        return false
                    }
                )
            }
            .map(
                to: { output in
                    IETF.RFC.`9110`.Authentication.Challenge(
                        scheme: .init(output.first.rawValue),
                        parameters: (output.second.first ?? []).dictionary
                    )
                },
                from: { challenge in
                    .init(
                        IETF.RFC.`9110`.Token(unchecked: challenge.scheme.name),
                        challenge.parameters.isEmpty ? [] : [[IETF.RFC.`9110`.Parameter].sorted(challenge.parameters)]
                    )
                }
            )
            .mapFailure { (failure) -> Failure in
                switch failure {
                case .left(let error): .expectedScheme(error)
                case .right(.element(.right(.element(let error)))): .invalidParameter(error)
                case .right: .expectedParameters
                }
            }
        }
    }

    extension IETF.RFC.`9110`.Authentication.Challenge {
        public static func parse(_ headerValue: String) -> Self? {
            var input = [Byte](utf8: headerValue)[...]
            do throws(Error) {
                return try coder.parse(&input)
            } catch {
                return nil
            }
        }
    }
#endif

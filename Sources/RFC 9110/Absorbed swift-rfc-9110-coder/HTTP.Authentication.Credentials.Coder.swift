#if Coder
    public import Byte
    public import Coder
    public import Cursor
    import Either
    import Pair
    import Parser
    import Serializer

    extension IETF.RFC.`9110`.Authentication.Credentials {
        public struct Coder<Input: Cursor.`Protocol`<Byte, Never>, Buffer: RangeReplaceableCollection<Byte>>: Coding {
            public init() {}
        }

        public static var coder: Coder<ArraySlice<Byte>, [Byte]> { .init() }
    }

    extension IETF.RFC.`9110`.Authentication.Credentials.Coder {
        public typealias Failure = IETF.RFC.`9110`.Authentication.Credentials.Error

        @Coder::Builder<Input, Buffer>
        public var body:
            some Coding
                & Parsing<Input, IETF.RFC.`9110`.Authentication.Credentials, Failure>
                & Serializing<IETF.RFC.`9110`.Authentication.Credentials, Buffer, Failure>
        {
            Coder::Coder(Input.self, Buffer.self) {
                IETF.RFC.`9110`.OWS.Coder()
                IETF.RFC.`9110`.Token.Coder()
                IETF.RFC.`9110`.RWS.Coder()
                IETF.RFC.`9110`.Authentication.Credentials.Remainder.Coder()
            }
            .map(
                to: { output in
                    IETF.RFC.`9110`.Authentication.Credentials(scheme: .init(output.first.rawValue), token: output.second)
                },
                from: { .init(IETF.RFC.`9110`.Token(unchecked: $0.scheme.name), $0.token) }
            )
            .mapFailure { (failure) -> Failure in
                switch failure {
                case .left(.left(let error)): .expectedScheme(error)
                default: .expectedToken
                }
            }
        }
    }

    extension IETF.RFC.`9110`.Authentication.Credentials {
        public static func parse(_ headerValue: String) -> Self? {
            var input = [Byte](utf8: headerValue)[...]
            do throws(Error) {
                return try coder.parse(&input)
            } catch {
                return nil
            }
        }
    }

    extension IETF.RFC.`9110`.Authentication.Credentials {
        enum Remainder {}
    }

    extension IETF.RFC.`9110`.Authentication.Credentials.Remainder {
        struct Coder<Input: Cursor.`Protocol`<Byte, Never>, Buffer: RangeReplaceableCollection<Byte>>: Coding {
        }

        enum Error: Swift::Error, Equatable {
            case empty
        }
    }

    extension IETF.RFC.`9110`.Authentication.Credentials.Remainder.Coder {
        typealias Output = String

        typealias Failure = IETF.RFC.`9110`.Authentication.Credentials.Remainder.Error

        borrowing func parse(_ input: inout Input) throws(Failure) -> String {
            var bytes: [UInt8] = []
            while let byte = input.next() {
                bytes.append(byte.bitPattern)
            }
            while let last = bytes.last, last == 0x20 || last == 0x09 {
                bytes.removeLast()
            }
            guard !bytes.isEmpty else { throw .empty }
            return String(decoding: bytes, as: UTF8.self)
        }

        borrowing func serialize(_ output: String, into buffer: inout Buffer) throws(Failure) {
            guard !output.isEmpty else { throw .empty }
            buffer.append(contentsOf: output.utf8.lazy.map(Byte.init(bitPattern:)))
        }
    }
#endif

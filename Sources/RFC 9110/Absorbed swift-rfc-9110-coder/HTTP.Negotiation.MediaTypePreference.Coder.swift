#if Coder
    public import Byte
    public import Coder
    public import Cursor
    import Parser
    import Serializer

    extension IETF.RFC.`9110`.Negotiation.MediaTypePreference {
        public struct Coder<Input: Cursor.`Protocol`<Byte, Never>, Buffer: RangeReplaceableCollection<Byte>>: Coding {
            public init() {}
        }

        public static var coder: Coder<ArraySlice<Byte>, [Byte]> { .init() }

        public enum Error: Swift::Error, Equatable {
            case mediaType(IETF.RFC.`9110`.MediaType.Error)
            case weight(IETF.RFC.`9110`.Negotiation.QualityValue.Error)
        }
    }

    extension IETF.RFC.`9110`.Negotiation.MediaTypePreference.Coder {
        public typealias Output = IETF.RFC.`9110`.Negotiation.MediaTypePreference

        public typealias Failure = IETF.RFC.`9110`.Negotiation.MediaTypePreference.Error

        public borrowing func parse(_ input: inout Input) throws(Failure) -> Output {
            var mediaType: IETF.RFC.`9110`.MediaType
            do throws(IETF.RFC.`9110`.MediaType.Error) {
                mediaType = try IETF.RFC.`9110`.MediaType.Coder<Input, Buffer>().parse(&input)
            } catch {
                throw .mediaType(error)
            }

            var quality = IETF.RFC.`9110`.Negotiation.QualityValue.default
            if let weight = mediaType.parameters.removeValue(forKey: "q") {
                guard let parsed = IETF.RFC.`9110`.Negotiation.QualityValue.parse(weight) else {
                    throw .weight(.invalidQValue)
                }
                quality = parsed
            }

            return Output(mediaType: mediaType, quality: quality)
        }

        public borrowing func serialize(_ output: Output, into buffer: inout Buffer) throws(Failure) {
            do throws(IETF.RFC.`9110`.MediaType.Error) {
                try IETF.RFC.`9110`.MediaType.Coder<Input, Buffer>().serialize(output.mediaType, into: &buffer)
            } catch {
                throw .mediaType(error)
            }

            guard output.quality != .default else { return }
            buffer.append(contentsOf: ";q=".utf8.lazy.map(Byte.init(bitPattern:)))
            do throws(IETF.RFC.`9110`.Negotiation.QualityValue.Error) {
                try IETF.RFC.`9110`.Negotiation.QualityValue.Coder<Input, Buffer>()
                    .serialize(output.quality, into: &buffer)
            } catch {
                throw .weight(error)
            }
        }
    }

    extension IETF.RFC.`9110`.Negotiation.MediaTypePreference {
        public static func parse(_ headerValue: String) -> [Self] {
            var input = [Byte](utf8: headerValue)[...]
            let preferences = (try? IETF.RFC.`9110`.Field.Value.List(coder).parse(&input)) ?? []

            return preferences.sorted { lhs, rhs in
                if lhs.quality != rhs.quality {
                    return lhs.quality > rhs.quality
                }
                if lhs.mediaType.type == "*" && rhs.mediaType.type != "*" { return false }
                if lhs.mediaType.type != "*" && rhs.mediaType.type == "*" { return true }
                if lhs.mediaType.subtype == "*" && rhs.mediaType.subtype != "*" { return false }
                if lhs.mediaType.subtype != "*" && rhs.mediaType.subtype == "*" { return true }
                return false
            }
        }
    }
#endif

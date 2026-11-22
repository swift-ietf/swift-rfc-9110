#if Coder
    import Byte
    import Coder
    import Cursor
    import Parser
    import RFC_5322
    import Standard_Library_Extensions

    extension IETF.RFC.`9110`.Precondition {

        public static func parseIfMatch(_ headerValue: String) -> IETF.RFC.`9110`.Precondition? {
            guard let etags = entityTags(in: headerValue) else { return nil }
            return .ifMatch(etags)
        }

        public static func parseIfNoneMatch(_ headerValue: String) -> IETF.RFC.`9110`.Precondition? {
            guard let etags = entityTags(in: headerValue) else { return nil }
            return .ifNoneMatch(etags)
        }

        public static func parseIfModifiedSince(_ headerValue: String) -> IETF.RFC.`9110`.Precondition? {
            guard let dateTime = IETF.RFC.`5322`.DateTime(httpDate: headerValue) else { return nil }
            return .ifModifiedSince(dateTime)
        }

        public static func parseIfUnmodifiedSince(_ headerValue: String) -> IETF.RFC.`9110`.Precondition? {
            guard let dateTime = IETF.RFC.`5322`.DateTime(httpDate: headerValue) else { return nil }
            return .ifUnmodifiedSince(dateTime)
        }

        public static func parseIfRange(_ headerValue: String) -> IETF.RFC.`9110`.Precondition? {
            let trimmed = String(headerValue.trimming(where: { $0.isWhitespace }))

            if let etag = IETF.RFC.`9110`.Representation.Validator.EntityTag.parse(trimmed) {
                return .ifRange(.entityTag(etag))
            }

            guard let dateTime = IETF.RFC.`5322`.DateTime(httpDate: trimmed) else { return nil }
            return .ifRange(.lastModified(dateTime))
        }

        private static func entityTags(in headerValue: String) -> [IETF.RFC.`9110`.Representation.Validator.EntityTag]? {
            var input = [Byte](utf8: headerValue)[...]
            let wildcard = Coder::Coder(ArraySlice<Byte>.self, [Byte].self) {
                IETF.RFC.`9110`.OWS.Coder()
                Coder::ConsumingLiteral<ArraySlice<Byte>, [Byte]>([Byte](utf8: "*"))
                IETF.RFC.`9110`.OWS.Coder()
            }
            if (try? wildcard.parse(&input)) != nil, input.isEmpty {
                return [wildcardTag]
            }

            input = [Byte](utf8: headerValue)[...]
            let etags = (try? IETF.RFC.`9110`.Field.Value.List(IETF.RFC.`9110`.Representation.Validator.EntityTag.coder).parse(&input)) ?? []
            return etags.isEmpty ? nil : etags
        }
    }

    extension IETF.RFC.`9110`.Precondition {

        public var headerValue: String {
            switch self {
            case .ifMatch(let etags):
                if etags.count == 1 && etags[0].value == "*" {
                    return "*"
                }
                return etags.map { $0.headerValue }.joined(separator: ", ")

            case .ifNoneMatch(let etags):
                if etags.count == 1 && etags[0].value == "*" {
                    return "*"
                }
                return etags.map { $0.headerValue }.joined(separator: ", ")

            case .ifModifiedSince(let date):
                return date.httpDate

            case .ifUnmodifiedSince(let date):
                return date.httpDate

            case .ifRange(.entityTag(let etag)):
                return etag.headerValue

            case .ifRange(.lastModified(let date)):
                return date.httpDate
            }
        }
    }

    extension IETF.RFC.`9110`.Precondition: CustomStringConvertible {

        public var description: String {
            "\(headerName): \(headerValue)"
        }
    }
#endif

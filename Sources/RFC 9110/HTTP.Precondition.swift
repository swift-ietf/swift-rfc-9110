public import RFC_5322

extension IETF.RFC.`9110` {

    public enum Precondition: Sendable, Equatable {

        case ifMatch([IETF.RFC.`9110`.Representation.Validator.EntityTag])

        case ifNoneMatch([IETF.RFC.`9110`.Representation.Validator.EntityTag])

        case ifModifiedSince(IETF.RFC.`5322`.DateTime)

        case ifUnmodifiedSince(IETF.RFC.`5322`.DateTime)

        case ifRange(IETF.RFC.`9110`.Representation.Validator)
    }
}

extension IETF.RFC.`9110`.Precondition {

    public static let wildcardTag = IETF.RFC.`9110`.Representation.Validator.EntityTag.strong("*")
}

extension IETF.RFC.`9110`.Precondition {

    public var headerName: String {
        switch self {
        case .ifMatch:
            return "If-Match"

        case .ifNoneMatch:
            return "If-None-Match"

        case .ifModifiedSince:
            return "If-Modified-Since"

        case .ifUnmodifiedSince:
            return "If-Unmodified-Since"

        case .ifRange:
            return "If-Range"
        }
    }
}

extension IETF.RFC.`9110`.Precondition {

    public func evaluate(
        currentETag: IETF.RFC.`9110`.Representation.Validator.EntityTag?,
        lastModified: IETF.RFC.`5322`.DateTime?
    ) -> Bool {
        switch self {
        case .ifMatch(let etags):
            guard let currentETag else {
                return false
            }

            if etags.contains(where: { $0.value == "*" }) {
                return true
            }

            return etags.contains(where: { IETF.RFC.`9110`.Representation.Validator.EntityTag.strongCompare($0, currentETag) })

        case .ifNoneMatch(let etags):
            guard let currentETag else {

                return true
            }

            if etags.contains(where: { $0.value == "*" }) {
                return false
            }

            return !etags.contains(where: { IETF.RFC.`9110`.Representation.Validator.EntityTag.weakCompare($0, currentETag) })

        case .ifModifiedSince(let date):
            guard let lastModified else {

                return true
            }

            return lastModified > date

        case .ifUnmodifiedSince(let date):
            guard let lastModified else {

                return true
            }

            return lastModified <= date

        case .ifRange(.entityTag(let etag)):
            guard let currentETag else {
                return false
            }

            return IETF.RFC.`9110`.Representation.Validator.EntityTag.strongCompare(etag, currentETag)

        case .ifRange(.lastModified(let date)):
            guard let lastModified else {
                return false
            }

            return lastModified <= date
        }
    }
}

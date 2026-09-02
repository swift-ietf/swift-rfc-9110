public import RFC_5322

extension RFC_9110 {

    public enum Precondition: Sendable, Equatable {

        case ifMatch([RFC_9110.Entity.Tag])

        case ifNoneMatch([RFC_9110.Entity.Tag])

        case ifModifiedSince(RFC_5322.DateTime)

        case ifUnmodifiedSince(RFC_5322.DateTime)

        case ifRange(Validator)
    }
}

extension RFC_9110.Precondition {

    public static let wildcardTag = RFC_9110.Entity.Tag.strong("*")
}

extension RFC_9110.Precondition {

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
            return String(date)

        case .ifUnmodifiedSince(let date):
            return String(date)

        case .ifRange(.etag(let etag)):
            return etag.headerValue

        case .ifRange(.date(let date)):
            return String(date)
        }
    }
}

extension RFC_9110.Precondition {

    public func evaluate(
        currentETag: RFC_9110.Entity.Tag?,
        lastModified: RFC_5322.DateTime?
    ) -> Bool {
        switch self {
        case .ifMatch(let etags):
            guard let currentETag else {
                return false
            }

            if etags.contains(where: { $0.value == "*" }) {
                return true
            }

            return etags.contains(where: { RFC_9110.Entity.Tag.strongCompare($0, currentETag) })

        case .ifNoneMatch(let etags):
            guard let currentETag else {

                return true
            }

            if etags.contains(where: { $0.value == "*" }) {
                return false
            }

            return !etags.contains(where: { RFC_9110.Entity.Tag.weakCompare($0, currentETag) })

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

        case .ifRange(.etag(let etag)):
            guard let currentETag else {
                return false
            }

            return RFC_9110.Entity.Tag.strongCompare(etag, currentETag)

        case .ifRange(.date(let date)):
            guard let lastModified else {
                return false
            }

            return lastModified <= date
        }
    }
}

extension RFC_9110.Precondition: CustomStringConvertible {
    public var description: String {
        return "\(headerName): \(headerValue)"
    }
}

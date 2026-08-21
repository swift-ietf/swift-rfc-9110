public import RFC_3986

extension RFC_9110.Request {

    public enum Target: Sendable, Equatable, Hashable, Codable {

        case origin(path: RFC_3986.URI.Path, query: RFC_3986.URI.Query?)

        case absolute(RFC_3986.URI)

        case authority(RFC_3986.URI.Authority)

        case asterisk

    }
}

extension RFC_9110.Request.Target {

    public var rawValue: String {
        switch self {
        case .origin(let path, let query):
            if let query, !query.isEmpty {
                return "\(path.description)?\(query.description)"
            } else {
                return path.description
            }

        case .absolute(let uri):
            return uri.value

        case .authority(let authority):
            return authority.rawValue

        case .asterisk:
            return "*"
        }
    }

    public var path: RFC_3986.URI.Path? {
        switch self {
        case .origin(let path, _):
            return path

        case .absolute(let uri):

            return uri.path

        case .authority, .asterisk:
            return nil
        }
    }

    public var query: RFC_3986.URI.Query? {
        switch self {
        case .origin(_, let query):
            return query

        case .absolute(let uri):

            return uri.query

        case .authority, .asterisk:
            return nil
        }
    }
}

extension RFC_9110.Request.Target: CustomStringConvertible {
    public var description: String {
        rawValue
    }
}

public import RFC_3986

extension RFC_9110 {
    public enum Target: Sendable, Equatable, Hashable {
        case origin(path: RFC_3986.URI.Path, query: RFC_3986.URI.Query?)
        case resource(RFC_3986.URI)
        case authority(RFC_3986.URI.Authority)
        case asterisk
    }
}

extension RFC_9110.Target {

    public init(unchecked resource: String) {
        guard resource.utf8.first == UInt8(ascii: "/") else {
            self = .resource(RFC_3986.URI(unchecked: resource))
            return
        }
        let parts = resource.split(separator: "?", maxSplits: 1, omittingEmptySubsequences: false)
        do {
            let path = try RFC_3986.URI.Path(parts[0])
            self = .origin(path: path, query: parts.count == 2 ? try RFC_3986.URI.Query(parts[1]) : nil)
        } catch {
            self = .resource(RFC_3986.URI(unchecked: resource))
        }
    }
}

extension RFC_9110.Target {
    public var reference: String? {
        switch self {
        case .origin(let path, let query):
            return query.map { "\(path)?\($0)" } ?? path.description

        case .resource(let resource):
            return resource.value

        case .authority, .asterisk:
            return nil
        }
    }
}

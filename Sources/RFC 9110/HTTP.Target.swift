public import RFC_3986

extension IETF.RFC.`9110` {
    public enum Target: Sendable, Equatable, Hashable {
        case origin(path: IETF.RFC.`3986`.URI.Path, query: IETF.RFC.`3986`.URI.Query?)
        case resource(IETF.RFC.`3986`.URI)
        case authority(IETF.RFC.`3986`.URI.Authority)
        case asterisk
    }
}

extension IETF.RFC.`9110`.Target {

    public init(unchecked resource: String) {
        guard resource.utf8.first == UInt8(ascii: "/") else {
            self = .resource(IETF.RFC.`3986`.URI(unchecked: resource))
            return
        }
        let parts = resource.split(separator: "?", maxSplits: 1, omittingEmptySubsequences: false)
        do {
            let path = try IETF.RFC.`3986`.URI.Path(parts[0])
            self = .origin(path: path, query: parts.count == 2 ? try IETF.RFC.`3986`.URI.Query(parts[1]) : nil)
        } catch {
            self = .resource(IETF.RFC.`3986`.URI(unchecked: resource))
        }
    }
}

extension IETF.RFC.`9110`.Target {
    public var path: IETF.RFC.`3986`.URI.Path? {
        switch self {
        case .origin(let path, _):
            return path

        case .resource(let resource):
            return resource.path

        case .authority, .asterisk:
            return nil
        }
    }
}

extension IETF.RFC.`9110`.Target {
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

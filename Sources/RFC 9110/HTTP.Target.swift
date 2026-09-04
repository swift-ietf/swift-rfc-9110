public import RFC_3986

extension RFC_9110 {
    public enum Target: Equatable, Hashable {
        case resource(RFC_3986.URI)
        case authority(RFC_3986.URI.Authority)
        case asterisk
    }
}

extension RFC_9110.Target {

    public init(unchecked resource: String) {
        self = .resource(RFC_3986.URI(unchecked: resource))
    }
}

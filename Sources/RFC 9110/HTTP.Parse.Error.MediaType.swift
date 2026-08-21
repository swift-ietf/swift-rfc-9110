extension RFC_9110.Parse.Error {

    public enum MediaType: Swift.Error, Sendable, Equatable {
        case expectedType
        case expectedSlash
        case expectedSubtype
    }
}

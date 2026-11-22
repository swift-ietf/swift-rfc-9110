public import RFC_5322

extension IETF.RFC.`9110`.Representation {

    public enum Validator: Sendable, Equatable {
        case entityTag(EntityTag)
        case lastModified(LastModified)
    }
}

extension IETF.RFC.`9110`.Representation.Validator {

    public typealias LastModified = IETF.RFC.`9110`.Date
}

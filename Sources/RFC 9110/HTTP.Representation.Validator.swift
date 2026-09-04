public import RFC_5322

extension RFC_9110.Representation {

    public enum Validator: Sendable, Equatable {
        case entityTag(EntityTag)
        case lastModified(LastModified)
    }
}

extension RFC_9110.Representation.Validator {

    public typealias LastModified = RFC_9110.Date
}

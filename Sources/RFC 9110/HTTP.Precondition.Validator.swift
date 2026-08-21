public import RFC_5322

extension RFC_9110.Precondition {

    public enum Validator: Sendable, Equatable {
        case etag(RFC_9110.Entity.Tag)
        case date(RFC_5322.DateTime)
    }
}

extension RFC_9110.Precondition.Validator: CustomStringConvertible {
    public var description: String {
        switch self {
        case .etag(let etag):
            return etag.description

        case .date(let date):
            return String(date)
        }
    }
}

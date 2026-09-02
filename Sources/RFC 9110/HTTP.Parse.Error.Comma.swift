extension RFC_9110.Parse.Error {

    public enum Comma: Swift.Error, Sendable, Equatable {

        case expectedComma
    }
}

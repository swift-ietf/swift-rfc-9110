extension RFC_9110.Parse.Error {

    public enum Token: Swift.Error, Sendable, Equatable {

        case expectedToken
    }
}

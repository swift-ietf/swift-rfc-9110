extension RFC_9110.Request {

    public enum Error: Swift.Error, Sendable {

        case invalidMethodForTarget(
            method: RFC_9110.Method,
            target: Target,
            reason: String
        )
    }
}

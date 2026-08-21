extension RFC_9110.Parse.Error {

    public enum Parameter: Swift.Error, Sendable, Equatable {
        case expectedToken
        case expectedEquals
        case expectedValue
        case invalidQuotedString(RFC_9110.Parse.Error.QuotedString)
    }
}

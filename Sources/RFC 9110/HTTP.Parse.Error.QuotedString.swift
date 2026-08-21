extension RFC_9110.Parse.Error {

    public enum QuotedString: Swift.Error, Sendable, Equatable {
        case expectedOpenQuote
        case unexpectedEndOfInput
        case invalidEscapeSequence
    }
}

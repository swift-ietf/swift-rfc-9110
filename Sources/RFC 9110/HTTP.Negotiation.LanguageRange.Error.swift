extension IETF.RFC.`9110`.Negotiation.LanguageRange {

    public enum Error: Swift::Error, Sendable, Equatable {
        case empty
        case invalid(String)
    }
}

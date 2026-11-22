extension IETF.RFC.`9110`.Field {

    public enum Error: Swift::Error, Sendable {
        case invalidFieldName(Name.Error)

        case invalidFieldValue(value: String, reason: String)
    }
}

extension RFC_9110.Header.Field {

    public enum Error: Swift.Error, Sendable {
        case invalidFieldName(Name.Error)

        case invalidFieldValue(value: String, reason: String)
    }
}

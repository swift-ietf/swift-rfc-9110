extension RFC_9110.Field {

    public enum Error: Swift.Error {
        case invalidFieldName(Name.Error)

        case invalidFieldValue(value: String, reason: String)
    }
}

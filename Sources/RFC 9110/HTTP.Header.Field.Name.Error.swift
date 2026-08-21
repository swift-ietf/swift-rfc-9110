extension RFC_9110.Header.Field.Name {
    public enum Error: Swift.Error, Sendable, Equatable {
        case empty
        case invalidCharacter(UInt8)
    }
}

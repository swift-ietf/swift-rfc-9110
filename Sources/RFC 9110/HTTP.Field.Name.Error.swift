extension RFC_9110.Field.Name {
    public enum Error: Swift.Error, Equatable {
        case empty
        case invalidCharacter(UInt8)
    }
}

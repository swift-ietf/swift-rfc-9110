extension IETF.RFC.`9110`.Field.Name {
    public enum Error: Swift::Error, Sendable, Equatable {
        case empty
        case invalidCharacter(UInt8)
    }
}

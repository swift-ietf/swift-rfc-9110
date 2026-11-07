
extension RFC_9110.Token {
    public enum Error: Swift::Error, Equatable {
        case empty
        case invalidCharacter(UInt8)
    }
}

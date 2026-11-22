extension IETF.RFC.`9110`.Authentication.Credentials {
    public enum Error: Swift::Error, Equatable {
        case expectedScheme(IETF.RFC.`9110`.Token.Error)
        case expectedToken
        case usernameContainsColon
    }
}

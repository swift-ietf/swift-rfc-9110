extension RFC_9110.Authentication.Credentials {
    public enum Error: Swift::Error, Equatable {
        case expectedScheme(RFC_9110.Token.Error)
        case expectedToken
        case usernameContainsColon
    }
}

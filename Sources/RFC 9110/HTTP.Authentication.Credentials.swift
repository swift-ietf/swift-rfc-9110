import Byte
import RFC_4648

extension RFC_9110.Authentication {

    public struct Credentials: Sendable, Equatable {

        public let scheme: Scheme

        public let token: String

        public init(scheme: Scheme, token: String) {
            self.scheme = scheme
            self.token = token
        }

    }
}

extension RFC_9110.Authentication.Credentials {

    public var headerValue: String {
        "\(scheme.name) \(token)"
    }
}

extension RFC_9110.Authentication.Credentials: CustomStringConvertible {
    public var description: String {
        headerValue
    }
}

extension RFC_9110.Authentication.Credentials: Codable {}

extension RFC_9110.Authentication.Credentials {

    public static func basic(
        username: String,
        password: String
    ) -> RFC_9110.Authentication.Credentials {
        let combined = "\(username):\(password)"
        let bytes: [Byte] = combined.utf8.map(Byte.init(bitPattern:))
        let encoded = bytes.base64.encoded()
        return Self(scheme: .basic, token: encoded)
    }

    public static func bearer(_ token: String) -> RFC_9110.Authentication.Credentials {
        Self(scheme: .bearer, token: token)
    }
}

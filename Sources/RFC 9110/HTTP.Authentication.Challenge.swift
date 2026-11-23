extension IETF.RFC.`9110`.Authentication {

    public struct Challenge: Sendable, Equatable {

        public let scheme: Scheme

        public var parameters: [String: String]

        public init(scheme: Scheme, parameters: [String: String] = [:]) {
            self.scheme = scheme
            self.parameters = parameters
        }

        public init(scheme: Scheme, realm: String) {
            self.scheme = scheme
            self.parameters = ["realm": realm]
        }

    }
}

extension IETF.RFC.`9110`.Authentication.Challenge {

    public var realm: String? {
        parameters["realm"]
    }

    public var headerValue: String {
        var result = scheme.name

        if !parameters.isEmpty {
            let params =
                parameters
                .sorted { $0.key < $1.key }
                .map { key, value in

                    guard !value.isEmpty, value.utf8.allSatisfy(IETF.RFC.`9110`.Token.isTchar) else {
                        var escaped = ""
                        for character in value {
                            if character == "\\" || character == "\"" {
                                escaped.append("\\")
                            }
                            escaped.append(character)
                        }
                        return "\(key)=\"\(escaped)\""
                    }
                    return "\(key)=\(value)"
                }
                .joined(separator: ", ")
            result += " \(params)"
        }

        return result
    }
}

extension IETF.RFC.`9110`.Authentication.Challenge: CustomStringConvertible {
    public var description: String {
        headerValue
    }
}

#if !hasFeature(Embedded)
    extension IETF.RFC.`9110`.Authentication.Challenge: Codable {}
#endif

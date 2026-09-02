import Byte
import Byte_Parser
import Byte_Standard_Library_Integration
import Parser

extension RFC_9110.Authentication {

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

extension RFC_9110.Authentication.Challenge {

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

                    if value.contains(" ") || value.contains(",") || value.contains("=") {
                        return "\(key)=\"\(value)\""
                    } else {
                        return "\(key)=\(value)"
                    }
                }
                .joined(separator: ", ")
            result += " \(params)"
        }

        return result
    }

    public static func parse(_ headerValue: String) -> Self? {
        var input = Byte.Input(utf8: headerValue)

        RFC_9110.Parse.OWS<Byte.Input>().parse(&input)

        let schemeBytes: [Byte]
        do throws(RFC_9110.Parse.Error.Token) {
            schemeBytes = try RFC_9110.Parse.Token<Byte.Input>().parse(&input)
        } catch {
            return nil
        }
        let scheme = RFC_9110.Authentication.Scheme(String(decoding: schemeBytes, as: UTF8.self))

        RFC_9110.Parse.OWS<Byte.Input>().parse(&input)
        guard !input.isEmpty else {
            return Self(scheme: scheme)
        }

        var parameters: [String: String] = [:]
        let parsed = RFC_9110.Parse.CommaSeparated(
            RFC_9110.Parse.Parameter<Byte.Input>()
        ).parse(&input)
        for param in parsed {
            parameters[String(decoding: param.name, as: UTF8.self)] = String(
                decoding: param.value,
                as: UTF8.self
            )
        }

        return Self(scheme: scheme, parameters: parameters)
    }
}

extension RFC_9110.Authentication.Challenge: CustomStringConvertible {
    public var description: String {
        headerValue
    }
}

extension RFC_9110.Authentication.Challenge: Codable {}

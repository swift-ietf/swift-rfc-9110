public import RFC_3986

// MARK: - Codable

extension RFC_9110.Request.Target {
    // reason: Decodable's `init(from:) throws` requirement is fixed by the stdlib protocol — `any Decoder` and untyped `throws` cannot be replaced with a generic constraint or typed throws without breaking Codable conformance.
    // swiftlint:disable:next no_any_protocol_existential typed_throws_required
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let form = try container.decode(String.self, forKey: .form)

        switch form {
        case "origin":
            let path = try container.decode(RFC_3986.URI.Path.self, forKey: .path)
            let query = try container.decodeIfPresent(RFC_3986.URI.Query.self, forKey: .query)
            self = .origin(path: path, query: query)

        case "absolute":
            let uriString = try container.decode(String.self, forKey: .uri)
            let uri = try RFC_3986.URI(uriString)
            self = .absolute(uri)

        case "authority":
            let authority = try container.decode(RFC_3986.URI.Authority.self, forKey: .authority)
            self = .authority(authority)

        case "asterisk":
            self = .asterisk

        default:
            throw DecodingError.dataCorruptedError(
                forKey: .form,
                in: container,
                debugDescription: "Unknown request-target form: \(form)"
            )
        }
    }

    // reason: Encodable's `encode(to:) throws` requirement is fixed by the stdlib protocol — `any Encoder` and untyped `throws` cannot be replaced with a generic constraint or typed throws without breaking Codable conformance.
    // swiftlint:disable:next no_any_protocol_existential typed_throws_required
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .origin(let path, let query):
            try container.encode("origin", forKey: .form)
            try container.encode(path, forKey: .path)
            if let query {
                try container.encode(query, forKey: .query)
            }

        case .absolute(let uri):
            try container.encode("absolute", forKey: .form)
            try container.encode(uri.value, forKey: .uri)

        case .authority(let authority):
            try container.encode("authority", forKey: .form)
            try container.encode(authority, forKey: .authority)

        case .asterisk:
            try container.encode("asterisk", forKey: .form)
        }
    }

    private enum CodingKeys: String, CodingKey {
        case form
        case path
        case query
        case uri
        case authority
    }
}

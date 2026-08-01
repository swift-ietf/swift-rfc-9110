import Byte_Primitives

// MARK: - Codable

extension RFC_9110.Request {
    // reason: Decodable's `init(from:) throws` requirement is fixed by the stdlib protocol — `any Decoder` and untyped `throws` cannot be replaced with a generic constraint or typed throws without breaking Codable conformance.
    // swiftlint:disable:next no_any_protocol_existential typed_throws_required
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let method = try container.decode(RFC_9110.Method.self, forKey: .method)
        let target = try container.decode(RFC_9110.Request.Target.self, forKey: .target)
        let headers = try container.decodeIfPresent(RFC_9110.Headers.self, forKey: .headers) ?? []
        let body = try container.decodeIfPresent([Byte].self, forKey: .body)

        self.init(
            method: method,
            target: target,
            headers: headers,
            body: body
        )
    }

    // reason: Encodable's `encode(to:) throws` requirement is fixed by the stdlib protocol — `any Encoder` and untyped `throws` cannot be replaced with a generic constraint or typed throws without breaking Codable conformance.
    // swiftlint:disable:next no_any_protocol_existential typed_throws_required
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(method, forKey: .method)
        try container.encode(target, forKey: .target)
        if !headers.isEmpty {
            try container.encode(Array(headers), forKey: .headers)
        }
        if let body {
            try container.encode(body, forKey: .body)
        }
    }

    private enum CodingKeys: String, CodingKey {
        case method
        case target
        case headers
        case body
    }
}

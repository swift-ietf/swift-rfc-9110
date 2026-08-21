import Byte_Primitives

extension RFC_9110.Response {
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let status = try container.decode(RFC_9110.Status.self, forKey: .status)
        let headers = try container.decodeIfPresent(RFC_9110.Headers.self, forKey: .headers) ?? []
        let body = try container.decodeIfPresent([Byte].self, forKey: .body)

        self.init(
            status: status,
            headers: headers,
            body: body
        )
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(status, forKey: .status)
        if !headers.isEmpty {
            try container.encode(Array(headers), forKey: .headers)
        }
        if let body {
            try container.encode(body, forKey: .body)
        }
    }

    private enum CodingKeys: String, CodingKey {
        case status
        case headers
        case body
    }
}

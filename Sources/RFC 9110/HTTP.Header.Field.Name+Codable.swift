// HTTP.Header.Field.Name+Codable.swift
// swift-rfc-9110

extension RFC_9110.Header.Field.Name {
    // swiftlint:disable:next no_any_protocol_existential typed_throws_required
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        do throws(Error) {
            try self.init(rawValue)
        } catch {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid HTTP header field name: \(error)"
            )
        }
    }

    // swiftlint:disable:next no_any_protocol_existential typed_throws_required
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

extension RFC_9110.Negotiation {

    public struct EncodingPreference: Sendable, Equatable {

        public let encoding: RFC_9110.Representation.Encoding

        public let quality: QualityValue

        public init(encoding: RFC_9110.Representation.Encoding, quality: QualityValue = .default) {
            self.encoding = encoding
            self.quality = quality
        }

    }
}

extension RFC_9110.Negotiation.EncodingPreference: CustomStringConvertible {
    public var description: String {
        if quality == .default {
            return encoding.value
        } else {
            return "\(encoding.value);q=\(quality)"
        }
    }
}

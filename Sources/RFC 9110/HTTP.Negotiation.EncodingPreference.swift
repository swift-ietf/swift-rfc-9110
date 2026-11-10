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
        guard quality != .default else {
            return encoding.value
        }
        return "\(encoding.value);q=\(quality)"
    }
}

extension RFC_9110.Negotiation.EncodingPreference {

    public static func best(
        of offered: [RFC_9110.Representation.Encoding],
        accepting preferences: [Self]
    ) -> RFC_9110.Representation.Encoding? {
        let wildcard = preferences.first { $0.encoding.value == "*" }?.quality
        var best: (encoding: RFC_9110.Representation.Encoding, quality: RFC_9110.Negotiation.QualityValue, named: Bool)?

        for encoding in offered {
            let named = preferences.first { $0.encoding == encoding }?.quality
            let quality: RFC_9110.Negotiation.QualityValue
            let isNamed: Bool
            if let named {
                quality = named
                isNamed = true
            } else if let wildcard {
                quality = wildcard
                isNamed = true
            } else if encoding == .identity {
                quality = .default
                isNamed = false
            } else {
                continue
            }
            guard quality > .zero else { continue }
            guard let current = best else {
                best = (encoding, quality, isNamed)
                continue
            }
            if (isNamed && !current.named) || (isNamed == current.named && quality > current.quality) {
                best = (encoding, quality, isNamed)
            }
        }
        return best?.encoding
    }
}

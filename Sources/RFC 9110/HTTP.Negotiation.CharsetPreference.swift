extension RFC_9110.Negotiation {

    public struct CharsetPreference: Sendable, Equatable {

        public let charset: String

        public let quality: QualityValue

        public init(charset: String, quality: QualityValue = .default) {
            self.charset = charset.lowercased()
            self.quality = quality
        }

    }
}

extension RFC_9110.Negotiation.CharsetPreference: CustomStringConvertible {
    public var description: String {
        if quality == .default {
            return charset
        } else {
            return "\(charset);q=\(quality)"
        }
    }
}

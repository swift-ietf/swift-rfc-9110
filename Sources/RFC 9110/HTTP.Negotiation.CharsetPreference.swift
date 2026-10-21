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
        guard quality != .default else {
            return charset
        }
        return "\(charset);q=\(quality)"
    }
}

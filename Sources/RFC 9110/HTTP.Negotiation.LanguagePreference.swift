extension RFC_9110.Negotiation {

    public struct LanguagePreference: Sendable, Equatable {

        public let language: LanguageRange

        public let quality: QualityValue

        public init(language: LanguageRange, quality: QualityValue = .default) {
            self.language = language
            self.quality = quality
        }

    }
}

extension RFC_9110.Negotiation.LanguagePreference: CustomStringConvertible {
    public var description: String {
        guard quality != .default else {
            return language.value
        }
        return "\(language.value);q=\(quality)"
    }
}

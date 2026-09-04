extension RFC_9110.Negotiation {

    public struct LanguagePreference: Sendable, Equatable {

        public let language: String

        public let quality: QualityValue

        public init(language: String, quality: QualityValue = .default) {
            self.language = language
            self.quality = quality
        }

    }
}

extension RFC_9110.Negotiation.LanguagePreference: CustomStringConvertible {
    public var description: String {
        if quality == .default {
            return language
        } else {
            return "\(language);q=\(quality)"
        }
    }
}

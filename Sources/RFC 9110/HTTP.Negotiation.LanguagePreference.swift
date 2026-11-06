extension RFC_9110.Negotiation {

    public struct LanguagePreference: Sendable, Equatable {

        // swift-linter:disable:next raw concept
        // REASON: Accept-Language holds an RFC 4647 language range, which may be * and is parsed as a Token; RFC_5646.LanguageTag refuses *, and no language-range type exists
        public let language: String

        public let quality: QualityValue

        // swift-linter:disable:next raw concept
        // REASON: Accept-Language holds an RFC 4647 language range, which may be * and is parsed as a Token; RFC_5646.LanguageTag refuses *, and no language-range type exists
        public init(language: String, quality: QualityValue = .default) {
            self.language = language
            self.quality = quality
        }

    }
}

extension RFC_9110.Negotiation.LanguagePreference: CustomStringConvertible {
    public var description: String {
        guard quality != .default else {
            return language
        }
        return "\(language);q=\(quality)"
    }
}

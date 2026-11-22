extension IETF.RFC.`9110` {

    public enum Negotiation {}
}

extension IETF.RFC.`9110`.Negotiation {

    public static func selectMediaType(
        from available: [IETF.RFC.`9110`.MediaType],
        preferences: [MediaTypePreference]
    ) -> IETF.RFC.`9110`.MediaType? {
        selectMediaTypes(from: available, preferences: preferences).first
    }

    public static func selectMediaTypes(
        from available: [IETF.RFC.`9110`.MediaType],
        preferences: [MediaTypePreference]
    ) -> [IETF.RFC.`9110`.MediaType] {
        var results: [(IETF.RFC.`9110`.MediaType, QualityValue)] = []

        for availableType in available {

            var bestQuality: QualityValue?

            for preference in preferences {
                if availableType.matches(preference.mediaType) {
                    if bestQuality.map({ preference.quality > $0 }) ?? true {
                        bestQuality = preference.quality
                    }
                }
            }

            if let quality = bestQuality, quality > .zero {
                results.append((availableType, quality))
            }
        }

        return
            results
            .sorted { $0.1 > $1.1 }
            .map { $0.0 }
    }
}

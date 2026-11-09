extension RFC_9110 {

    public enum Negotiation {}
}

extension RFC_9110.Negotiation {

    public static func selectMediaType(
        from available: [RFC_9110.MediaType],
        preferences: [MediaTypePreference]
    ) -> RFC_9110.MediaType? {
        selectMediaTypes(from: available, preferences: preferences).first
    }

    public static func selectMediaTypes(
        from available: [RFC_9110.MediaType],
        preferences: [MediaTypePreference]
    ) -> [RFC_9110.MediaType] {
        var results: [(RFC_9110.MediaType, QualityValue)] = []

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

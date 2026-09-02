extension RFC_9110.Message.Content {

    public enum Negotiation {}
}

extension RFC_9110.Message.Content.Negotiation {

    public static func selectMediaType(
        from available: [RFC_9110.MediaType],
        preferences: [MediaTypePreference]
    ) -> RFC_9110.MediaType? {
        for preference in preferences {

            for availableType in available {
                if availableType.matches(preference.mediaType) {
                    return availableType
                }
            }
        }

        return nil
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
                    if bestQuality == nil || preference.quality > bestQuality! {
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

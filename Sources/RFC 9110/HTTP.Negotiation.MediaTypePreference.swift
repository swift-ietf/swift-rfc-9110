extension RFC_9110.Negotiation {

    public struct MediaTypePreference: Sendable, Equatable {

        public let mediaType: RFC_9110.MediaType

        public let quality: QualityValue

        public init(mediaType: RFC_9110.MediaType, quality: QualityValue = .default) {
            self.mediaType = mediaType
            self.quality = quality
        }

    }
}

extension RFC_9110.Negotiation.MediaTypePreference: CustomStringConvertible {
    public var description: String {
        guard quality != .default else {
            return mediaType.value
        }
        return "\(mediaType.value);q=\(quality)"
    }
}

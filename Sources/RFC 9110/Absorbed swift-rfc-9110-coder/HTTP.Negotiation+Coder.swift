#if Coder
    extension IETF.RFC.`9110`.Negotiation {

        public static func selectMediaType(
            from available: [IETF.RFC.`9110`.MediaType],
            acceptHeader: String
        ) -> IETF.RFC.`9110`.MediaType? {
            selectMediaType(from: available, preferences: MediaTypePreference.parse(acceptHeader))
        }

        public static func selectMediaTypes(
            from available: [IETF.RFC.`9110`.MediaType],
            acceptHeader: String
        ) -> [IETF.RFC.`9110`.MediaType] {
            selectMediaTypes(from: available, preferences: MediaTypePreference.parse(acceptHeader))
        }
    }
#endif

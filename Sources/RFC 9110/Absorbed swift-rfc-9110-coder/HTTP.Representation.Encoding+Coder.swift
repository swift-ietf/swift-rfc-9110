#if Coder
    extension IETF.RFC.`9110`.Representation.Encoding {

        public static func parse(_ headerValue: String) -> [Self] {
            IETF.RFC.`9110`.Field.Value.tokens(in: headerValue).map { Self($0) }
        }
    }

    extension IETF.RFC.`9110`.Representation.Language {

        public static func parse(_ headerValue: String) -> [Self] {
            IETF.RFC.`9110`.Field.Value.tokens(in: headerValue).map { Self($0) }
        }
    }
#endif

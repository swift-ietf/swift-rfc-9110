#if Coder
    import Standard_Library_Extensions

    extension IETF.RFC.`9110`.Negotiation.Vary {

        public static func parse(_ headerValue: String) -> IETF.RFC.`9110`.Negotiation.Vary? {
            let trimmed = String(headerValue.trimming(where: { $0.isWhitespace }))

            if trimmed == "*" {
                return .all
            }

            let names = IETF.RFC.`9110`.Field.Value.tokens(in: headerValue)

            guard !names.isEmpty else {
                return nil
            }

            return IETF.RFC.`9110`.Negotiation.Vary(fieldNames: names)
        }
    }

    extension IETF.RFC.`9110`.Negotiation.Vary: LosslessStringConvertible {

        public init?(_ description: String) {
            guard let parsed = Self.parse(description) else { return nil }
            self = parsed
        }
    }
#endif

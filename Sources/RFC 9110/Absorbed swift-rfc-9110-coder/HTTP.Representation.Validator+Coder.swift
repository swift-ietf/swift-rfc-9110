#if Coder
    extension RFC_9110.Representation.Validator: CustomStringConvertible {

        public var description: String {
            switch self {
            case .entityTag(let entityTag):
                return entityTag.headerValue

            case .lastModified(let lastModified):
                return lastModified.httpDate
            }
        }
    }
#endif

extension RFC_9110.Header.Field {

    public struct Name: Hashable, Sendable, Codable {

        public let rawValue: String

        public init(_ rawValue: String) throws(Error) {
            guard !rawValue.isEmpty else { throw .empty }
            for byte in rawValue.utf8 where !Self.isTchar(byte) {
                throw .invalidCharacter(byte)
            }
            self.rawValue = rawValue
        }

        private init(unchecked rawValue: String) {
            self.rawValue = rawValue
        }
    }
}

extension RFC_9110.Header.Field.Name {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue.lowercased())
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {

        lhs.rawValue.lowercased() == rhs.rawValue.lowercased()
    }
}

extension RFC_9110.Header.Field.Name {
    private static func isTchar(_ byte: UInt8) -> Bool {
        switch byte {
        case 0x21, 0x23, 0x24, 0x25, 0x26, 0x27, 0x2A, 0x2B,
            0x2D, 0x2E, 0x5E, 0x5F, 0x60, 0x7C, 0x7E,
            0x30...0x39, 0x41...0x5A, 0x61...0x7A:
            true

        default:
            false
        }
    }
}

extension RFC_9110.Header.Field.Name: CustomStringConvertible {
    public var description: String {
        rawValue
    }
}

extension RFC_9110.Header.Field.Name {

    public static let cacheControl = Self(unchecked: "Cache-Control")

    public static let expect = Self(unchecked: "Expect")

    public static let host = Self(unchecked: "Host")

    public static let maxForwards = Self(unchecked: "Max-Forwards")

    public static let pragma = Self(unchecked: "Pragma")

    public static let range = Self(unchecked: "Range")

    public static let te = Self(unchecked: "TE")

    public static let from = Self(unchecked: "From")

    public static let referer = Self(unchecked: "Referer")

    public static let userAgent = Self(unchecked: "User-Agent")

    public static let accept = Self(unchecked: "Accept")

    public static let acceptCharset = Self(unchecked: "Accept-Charset")

    public static let acceptEncoding = Self(unchecked: "Accept-Encoding")

    public static let acceptLanguage = Self(unchecked: "Accept-Language")

    public static let authorization = Self(unchecked: "Authorization")

    public static let proxyAuthorization = Self(unchecked: "Proxy-Authorization")

    public static let wwwAuthenticate = Self(unchecked: "WWW-Authenticate")

    public static let proxyAuthenticate = Self(unchecked: "Proxy-Authenticate")

    public static let age = Self(unchecked: "Age")

    public static let expires = Self(unchecked: "Expires")

    public static let date = Self(unchecked: "Date")

    public static let location = Self(unchecked: "Location")

    public static let retryAfter = Self(unchecked: "Retry-After")

    public static let vary = Self(unchecked: "Vary")

    public static let server = Self(unchecked: "Server")

    public static let contentType = Self(unchecked: "Content-Type")

    public static let contentEncoding = Self(unchecked: "Content-Encoding")

    public static let contentLanguage = Self(unchecked: "Content-Language")

    public static let contentLocation = Self(unchecked: "Content-Location")

    public static let contentLength = Self(unchecked: "Content-Length")

    public static let contentRange = Self(unchecked: "Content-Range")

    public static let trailer = Self(unchecked: "Trailer")

    public static let transferEncoding = Self(unchecked: "Transfer-Encoding")

    public static let etag = Self(unchecked: "ETag")

    public static let lastModified = Self(unchecked: "Last-Modified")

    public static let ifMatch = Self(unchecked: "If-Match")

    public static let ifNoneMatch = Self(unchecked: "If-None-Match")

    public static let ifModifiedSince = Self(unchecked: "If-Modified-Since")

    public static let ifUnmodifiedSince = Self(unchecked: "If-Unmodified-Since")

    public static let ifRange = Self(unchecked: "If-Range")

    public static let connection = Self(unchecked: "Connection")

    public static let close = Self(unchecked: "close")

    public static let keepAlive = Self(unchecked: "Keep-Alive")

    public static let allow = Self(unchecked: "Allow")
}

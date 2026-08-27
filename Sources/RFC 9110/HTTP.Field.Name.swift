extension RFC_9110.Field {

    public struct Name: Hashable {

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

extension RFC_9110.Field.Name {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue.lowercased())
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {

        lhs.rawValue.lowercased() == rhs.rawValue.lowercased()
    }
}

extension RFC_9110.Field.Name {
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

extension RFC_9110.Field.Name: CustomStringConvertible {
    public var description: String {
        rawValue
    }
}

extension RFC_9110.Field.Name {

    public static var cacheControl: Self { Self(unchecked: "Cache-Control") }

    public static var expect: Self { Self(unchecked: "Expect") }

    public static var host: Self { Self(unchecked: "Host") }

    public static var maxForwards: Self { Self(unchecked: "Max-Forwards") }

    public static var pragma: Self { Self(unchecked: "Pragma") }

    public static var range: Self { Self(unchecked: "Range") }

    public static var te: Self { Self(unchecked: "TE") }

    public static var from: Self { Self(unchecked: "From") }

    public static var referer: Self { Self(unchecked: "Referer") }

    public static var userAgent: Self { Self(unchecked: "User-Agent") }

    public static var accept: Self { Self(unchecked: "Accept") }

    public static var acceptCharset: Self { Self(unchecked: "Accept-Charset") }

    public static var acceptEncoding: Self { Self(unchecked: "Accept-Encoding") }

    public static var acceptLanguage: Self { Self(unchecked: "Accept-Language") }

    public static var authorization: Self { Self(unchecked: "Authorization") }

    public static var proxyAuthorization: Self { Self(unchecked: "Proxy-Authorization") }

    public static var wwwAuthenticate: Self { Self(unchecked: "WWW-Authenticate") }

    public static var proxyAuthenticate: Self { Self(unchecked: "Proxy-Authenticate") }

    public static var age: Self { Self(unchecked: "Age") }

    public static var expires: Self { Self(unchecked: "Expires") }

    public static var date: Self { Self(unchecked: "Date") }

    public static var location: Self { Self(unchecked: "Location") }

    public static var retryAfter: Self { Self(unchecked: "Retry-After") }

    public static var vary: Self { Self(unchecked: "Vary") }

    public static var server: Self { Self(unchecked: "Server") }

    public static var contentType: Self { Self(unchecked: "Content-Type") }

    public static var contentEncoding: Self { Self(unchecked: "Content-Encoding") }

    public static var contentLanguage: Self { Self(unchecked: "Content-Language") }

    public static var contentLocation: Self { Self(unchecked: "Content-Location") }

    public static var contentLength: Self { Self(unchecked: "Content-Length") }

    public static var contentRange: Self { Self(unchecked: "Content-Range") }

    public static var trailer: Self { Self(unchecked: "Trailer") }

    public static var transferEncoding: Self { Self(unchecked: "Transfer-Encoding") }

    public static var etag: Self { Self(unchecked: "ETag") }

    public static var lastModified: Self { Self(unchecked: "Last-Modified") }

    public static var ifMatch: Self { Self(unchecked: "If-Match") }

    public static var ifNoneMatch: Self { Self(unchecked: "If-None-Match") }

    public static var ifModifiedSince: Self { Self(unchecked: "If-Modified-Since") }

    public static var ifUnmodifiedSince: Self { Self(unchecked: "If-Unmodified-Since") }

    public static var ifRange: Self { Self(unchecked: "If-Range") }

    public static var connection: Self { Self(unchecked: "Connection") }

    public static var close: Self { Self(unchecked: "close") }

    public static var keepAlive: Self { Self(unchecked: "Keep-Alive") }

    public static var allow: Self { Self(unchecked: "Allow") }
}

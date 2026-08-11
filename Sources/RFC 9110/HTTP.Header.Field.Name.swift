// HTTP.Header.Field.Name.swift
// swift-rfc-9110

extension RFC_9110.Header.Field {
    /// An HTTP header field name per RFC 9110 Section 5.1
    ///
    /// Header field names are case-insensitive tokens consisting of
    /// alphanumeric characters and certain special characters.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let contentType = try HTTP.Header.Field.Name("Content-Type")
    /// let accept = try HTTP.Header.Field.Name("Accept")
    /// let custom = try HTTP.Header.Field.Name("X-Custom-Header")
    /// ```
    ///
    /// ## RFC 9110 Syntax
    ///
    /// From RFC 9110 Section 5.1:
    /// ```
    /// field-name     = token
    /// token          = 1*tchar
    /// tchar          = "!" / "#" / "$" / "%" / "&" / "'" / "*"
    ///                / "+" / "-" / "." / "^" / "_" / "`" / "|" / "~"
    ///                / DIGIT / ALPHA
    /// ```
    ///
    /// ## Reference
    ///
    /// - [RFC 9110 Section 5.1: Field Names](https://www.rfc-editor.org/rfc/rfc9110.html#section-5.1)
    public struct Name: Hashable, Sendable, Codable {
        /// The header field name
        ///
        /// Note: Header field names are case-insensitive per RFC 9110,
        /// but we preserve the original case for display purposes.
        public let rawValue: String

        /// Creates a header field name
        ///
        /// - Parameter rawValue: The header field name
        ///
        /// - Throws: `Name.Error` when the name is empty or contains a non-`tchar` byte.
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
    /// Hash value (case-insensitive per RFC 9110)
    public func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue.lowercased())
    }

    /// Equality comparison (case-insensitive per RFC 9110)
    public static func == (lhs: Self, rhs: Self) -> Bool {
        // swift-linter:disable:next raw value access
        // REASON: Name's own Equatable conformance — same-package implementation
        // reading its own wrapped value at the type's boundary.
        // swift-linter:disable:next chained rawvalue access
        // REASON: typed-system bottom-out — the wrapper's own case-insensitive
        // comparison boundary.
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

// MARK: - CustomStringConvertible

extension RFC_9110.Header.Field.Name: CustomStringConvertible {
    public var description: String {
        rawValue
    }
}

// MARK: - Common Header Names

extension RFC_9110.Header.Field.Name {
    // MARK: - Control Data (RFC 9110 Section 6.6)

    /// Cache-Control header (RFC 9110 Section 5.2)
    public static let cacheControl = Self(unchecked: "Cache-Control")

    /// Expect header (RFC 9110 Section 10.1.1)
    public static let expect = Self(unchecked: "Expect")

    /// Host header (RFC 9110 Section 7.2)
    public static let host = Self(unchecked: "Host")

    /// Max-Forwards header (RFC 9110 Section 7.6.2)
    public static let maxForwards = Self(unchecked: "Max-Forwards")

    /// Pragma header (RFC 9110 Section 5.4)
    public static let pragma = Self(unchecked: "Pragma")

    /// Range header (RFC 9110 Section 14.2)
    public static let range = Self(unchecked: "Range")

    /// TE header (RFC 9110 Section 10.1.4)
    public static let te = Self(unchecked: "TE")

    // MARK: - Request Context (RFC 9110 Section 10.1)

    /// From header (RFC 9110 Section 10.1.2)
    public static let from = Self(unchecked: "From")

    /// Referer header (RFC 9110 Section 10.1.3)
    public static let referer = Self(unchecked: "Referer")

    /// User-Agent header (RFC 9110 Section 10.1.5)
    public static let userAgent = Self(unchecked: "User-Agent")

    // MARK: - Request Content Negotiation (RFC 9110 Section 12)

    /// Accept header (RFC 9110 Section 12.5.1)
    public static let accept = Self(unchecked: "Accept")

    /// Accept-Charset header (RFC 9110 Section 12.5.2)
    public static let acceptCharset = Self(unchecked: "Accept-Charset")

    /// Accept-Encoding header (RFC 9110 Section 12.5.3)
    public static let acceptEncoding = Self(unchecked: "Accept-Encoding")

    /// Accept-Language header (RFC 9110 Section 12.5.4)
    public static let acceptLanguage = Self(unchecked: "Accept-Language")

    // MARK: - Authentication (RFC 9110 Section 11)

    /// Authorization header (RFC 9110 Section 11.6.2)
    public static let authorization = Self(unchecked: "Authorization")

    /// Proxy-Authorization header (RFC 9110 Section 11.7.2)
    public static let proxyAuthorization = Self(unchecked: "Proxy-Authorization")

    /// WWW-Authenticate header (RFC 9110 Section 11.6.1)
    public static let wwwAuthenticate = Self(unchecked: "WWW-Authenticate")

    /// Proxy-Authenticate header (RFC 9110 Section 11.7.1)
    public static let proxyAuthenticate = Self(unchecked: "Proxy-Authenticate")

    // MARK: - Response Control Data (RFC 9110 Section 10.2)

    /// Age header (RFC 9110 Section 5.1)
    public static let age = Self(unchecked: "Age")

    /// Expires header (RFC 9110 Section 5.3)
    public static let expires = Self(unchecked: "Expires")

    /// Date header (RFC 9110 Section 6.6.1)
    public static let date = Self(unchecked: "Date")

    /// Location header (RFC 9110 Section 10.2.2)
    public static let location = Self(unchecked: "Location")

    /// Retry-After header (RFC 9110 Section 10.2.3)
    public static let retryAfter = Self(unchecked: "Retry-After")

    /// Vary header (RFC 9110 Section 12.5.5)
    public static let vary = Self(unchecked: "Vary")

    /// Server header (RFC 9110 Section 10.2.4)
    public static let server = Self(unchecked: "Server")

    // MARK: - Representation Metadata (RFC 9110 Section 8.3)

    /// Content-Type header (RFC 9110 Section 8.3)
    public static let contentType = Self(unchecked: "Content-Type")

    /// Content-Encoding header (RFC 9110 Section 8.4)
    public static let contentEncoding = Self(unchecked: "Content-Encoding")

    /// Content-Language header (RFC 9110 Section 8.5)
    public static let contentLanguage = Self(unchecked: "Content-Language")

    /// Content-Location header (RFC 9110 Section 8.7)
    public static let contentLocation = Self(unchecked: "Content-Location")

    // MARK: - Payload (RFC 9110 Section 8.6)

    /// Content-Length header (RFC 9110 Section 8.6)
    public static let contentLength = Self(unchecked: "Content-Length")

    /// Content-Range header (RFC 9110 Section 14.4)
    public static let contentRange = Self(unchecked: "Content-Range")

    /// Trailer header (RFC 9110 Section 6.6.2)
    public static let trailer = Self(unchecked: "Trailer")

    /// Transfer-Encoding header (RFC 9110 Section 6.1)
    public static let transferEncoding = Self(unchecked: "Transfer-Encoding")

    // MARK: - Validators (RFC 9110 Section 8.8)

    /// ETag header (RFC 9110 Section 8.8.3)
    public static let etag = Self(unchecked: "ETag")

    /// Last-Modified header (RFC 9110 Section 8.8.2)
    public static let lastModified = Self(unchecked: "Last-Modified")

    // MARK: - Conditional Requests (RFC 9110 Section 13)

    /// If-Match header (RFC 9110 Section 13.1.1)
    public static let ifMatch = Self(unchecked: "If-Match")

    /// If-None-Match header (RFC 9110 Section 13.1.2)
    public static let ifNoneMatch = Self(unchecked: "If-None-Match")

    /// If-Modified-Since header (RFC 9110 Section 13.1.3)
    public static let ifModifiedSince = Self(unchecked: "If-Modified-Since")

    /// If-Unmodified-Since header (RFC 9110 Section 13.1.4)
    public static let ifUnmodifiedSince = Self(unchecked: "If-Unmodified-Since")

    /// If-Range header (RFC 9110 Section 13.1.5)
    public static let ifRange = Self(unchecked: "If-Range")

    // MARK: - Connection Management (RFC 9110 Section 7.6.1)

    /// Connection header (RFC 9110 Section 7.6.1)
    public static let connection = Self(unchecked: "Connection")

    /// Close connection token
    public static let close = Self(unchecked: "close")

    /// Keep-Alive header
    public static let keepAlive = Self(unchecked: "Keep-Alive")

    // MARK: - Other

    /// Allow header (RFC 9110 Section 10.2.1)
    public static let allow = Self(unchecked: "Allow")
}

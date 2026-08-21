extension RFC_9110 {

    public struct Status: Hashable, Sendable, Codable {

        public let code: Int

        public let reasonPhrase: String?

        public init(_ code: Int, _ reasonPhrase: String? = nil) {
            self.code = code
            self.reasonPhrase = reasonPhrase
        }
    }
}

extension RFC_9110.Status {

    public var isInformational: Bool {
        (100...199).contains(code)
    }

    public var isSuccessful: Bool {
        (200...299).contains(code)
    }

    public var isRedirection: Bool {
        (300...399).contains(code)
    }

    public var isClientError: Bool {
        (400...499).contains(code)
    }

    public var isServerError: Bool {
        (500...599).contains(code)
    }

    public var isFinal: Bool {
        !isInformational
    }
}

extension RFC_9110.Status {

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.code == rhs.code
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(code)
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.code = try container.decode(Int.self)
        self.reasonPhrase = nil
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(code)
    }
}

extension RFC_9110.Status: CustomStringConvertible {
    public var description: String {
        if let reasonPhrase {
            return "\(code) \(reasonPhrase)"
        } else {
            return "\(code)"
        }
    }
}

extension RFC_9110.Status: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self.init(value)
    }
}

extension RFC_9110.Status: Comparable {

    public static func < (lhs: RFC_9110.Status, rhs: RFC_9110.Status) -> Bool {
        lhs.code < rhs.code
    }
}

extension RFC_9110.Status {

    public static let `continue` = Self(100, "Continue")

    public static let switchingProtocols = Self(101, "Switching Protocols")

    public static let ok = Self(200, "OK")

    public static let created = Self(201, "Created")

    public static let accepted = Self(202, "Accepted")

    public static let nonAuthoritativeInformation = Self(203, "Non-Authoritative Information")

    public static let noContent = Self(204, "No Content")

    public static let resetContent = Self(205, "Reset Content")

    public static let partialContent = Self(206, "Partial Content")

    public static let multipleChoices = Self(300, "Multiple Choices")

    public static let movedPermanently = Self(301, "Moved Permanently")

    public static let found = Self(302, "Found")

    public static let seeOther = Self(303, "See Other")

    public static let notModified = Self(304, "Not Modified")

    public static let useProxy = Self(305, "Use Proxy")

    public static let temporaryRedirect = Self(307, "Temporary Redirect")

    public static let permanentRedirect = Self(308, "Permanent Redirect")

    public static let badRequest = Self(400, "Bad Request")

    public static let unauthorized = Self(401, "Unauthorized")

    public static let paymentRequired = Self(402, "Payment Required")

    public static let forbidden = Self(403, "Forbidden")

    public static let notFound = Self(404, "Not Found")

    public static let methodNotAllowed = Self(405, "Method Not Allowed")

    public static let notAcceptable = Self(406, "Not Acceptable")

    public static let proxyAuthenticationRequired = Self(407, "Proxy Authentication Required")

    public static let requestTimeout = Self(408, "Request Timeout")

    public static let conflict = Self(409, "Conflict")

    public static let gone = Self(410, "Gone")

    public static let lengthRequired = Self(411, "Length Required")

    public static let preconditionFailed = Self(412, "Precondition Failed")

    public static let contentTooLarge = Self(413, "Content Too Large")

    public static let uriTooLong = Self(414, "URI Too Long")

    public static let unsupportedMediaType = Self(415, "Unsupported Media Type")

    public static let rangeNotSatisfiable = Self(416, "Range Not Satisfiable")

    public static let expectationFailed = Self(417, "Expectation Failed")

    public static let misdirectedRequest = Self(421, "Misdirected Request")

    public static let unprocessableContent = Self(422, "Unprocessable Content")

    public static let upgradeRequired = Self(426, "Upgrade Required")

    public static let internalServerError = Self(500, "Internal Server Error")

    public static let notImplemented = Self(501, "Not Implemented")

    public static let badGateway = Self(502, "Bad Gateway")

    public static let serviceUnavailable = Self(503, "Service Unavailable")

    public static let gatewayTimeout = Self(504, "Gateway Timeout")

    public static let httpVersionNotSupported = Self(505, "HTTP Version Not Supported")
}

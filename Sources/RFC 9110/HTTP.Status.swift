extension RFC_9110 {

    public struct Status: Hashable {

        public let code: Int

        public init(_ code: Int) {
            self.code = code
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

}

extension RFC_9110.Status: CustomStringConvertible {
    public var description: String {
        "\(code)"
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

    public static var `continue`: Self { Self(100) }

    public static var switchingProtocols: Self { Self(101) }

    public static var ok: Self { Self(200) }

    public static var created: Self { Self(201) }

    public static var accepted: Self { Self(202) }

    public static var nonAuthoritativeInformation: Self { Self(203) }

    public static var noContent: Self { Self(204) }

    public static var resetContent: Self { Self(205) }

    public static var partialContent: Self { Self(206) }

    public static var multipleChoices: Self { Self(300) }

    public static var movedPermanently: Self { Self(301) }

    public static var found: Self { Self(302) }

    public static var seeOther: Self { Self(303) }

    public static var notModified: Self { Self(304) }

    public static var useProxy: Self { Self(305) }

    public static var temporaryRedirect: Self { Self(307) }

    public static var permanentRedirect: Self { Self(308) }

    public static var badRequest: Self { Self(400) }

    public static var unauthorized: Self { Self(401) }

    public static var paymentRequired: Self { Self(402) }

    public static var forbidden: Self { Self(403) }

    public static var notFound: Self { Self(404) }

    public static var methodNotAllowed: Self { Self(405) }

    public static var notAcceptable: Self { Self(406) }

    public static var proxyAuthenticationRequired: Self { Self(407) }

    public static var requestTimeout: Self { Self(408) }

    public static var conflict: Self { Self(409) }

    public static var gone: Self { Self(410) }

    public static var lengthRequired: Self { Self(411) }

    public static var preconditionFailed: Self { Self(412) }

    public static var contentTooLarge: Self { Self(413) }

    public static var uriTooLong: Self { Self(414) }

    public static var unsupportedMediaType: Self { Self(415) }

    public static var rangeNotSatisfiable: Self { Self(416) }

    public static var expectationFailed: Self { Self(417) }

    public static var misdirectedRequest: Self { Self(421) }

    public static var unprocessableContent: Self { Self(422) }

    public static var upgradeRequired: Self { Self(426) }

    public static var internalServerError: Self { Self(500) }

    public static var notImplemented: Self { Self(501) }

    public static var badGateway: Self { Self(502) }

    public static var serviceUnavailable: Self { Self(503) }

    public static var gatewayTimeout: Self { Self(504) }

    public static var httpVersionNotSupported: Self { Self(505) }
}

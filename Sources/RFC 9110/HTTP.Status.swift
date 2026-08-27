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

    public static let `continue` = Self(100)

    public static let switchingProtocols = Self(101)

    public static let ok = Self(200)

    public static let created = Self(201)

    public static let accepted = Self(202)

    public static let nonAuthoritativeInformation = Self(203)

    public static let noContent = Self(204)

    public static let resetContent = Self(205)

    public static let partialContent = Self(206)

    public static let multipleChoices = Self(300)

    public static let movedPermanently = Self(301)

    public static let found = Self(302)

    public static let seeOther = Self(303)

    public static let notModified = Self(304)

    public static let useProxy = Self(305)

    public static let temporaryRedirect = Self(307)

    public static let permanentRedirect = Self(308)

    public static let badRequest = Self(400)

    public static let unauthorized = Self(401)

    public static let paymentRequired = Self(402)

    public static let forbidden = Self(403)

    public static let notFound = Self(404)

    public static let methodNotAllowed = Self(405)

    public static let notAcceptable = Self(406)

    public static let proxyAuthenticationRequired = Self(407)

    public static let requestTimeout = Self(408)

    public static let conflict = Self(409)

    public static let gone = Self(410)

    public static let lengthRequired = Self(411)

    public static let preconditionFailed = Self(412)

    public static let contentTooLarge = Self(413)

    public static let uriTooLong = Self(414)

    public static let unsupportedMediaType = Self(415)

    public static let rangeNotSatisfiable = Self(416)

    public static let expectationFailed = Self(417)

    public static let misdirectedRequest = Self(421)

    public static let unprocessableContent = Self(422)

    public static let upgradeRequired = Self(426)

    public static let internalServerError = Self(500)

    public static let notImplemented = Self(501)

    public static let badGateway = Self(502)

    public static let serviceUnavailable = Self(503)

    public static let gatewayTimeout = Self(504)

    public static let httpVersionNotSupported = Self(505)
}

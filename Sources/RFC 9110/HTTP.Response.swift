public import Byte_Primitives

extension RFC_9110 {

    public struct Response: Sendable, Equatable, Hashable, Codable {

        public var status: RFC_9110.Status

        public var headers: RFC_9110.Headers

        public var body: [Byte]?

        public init(
            status: RFC_9110.Status,
            headers: RFC_9110.Headers = [],
            body: [Byte]? = nil
        ) {
            self.status = status
            self.headers = headers
            self.body = body
        }
    }
}

extension RFC_9110.Response {

    public func header(_ name: RFC_9110.Header.Field.Name) -> [RFC_9110.Header.Field.Value] {
        headers[name] ?? []
    }

    public func firstHeader(_ name: RFC_9110.Header.Field.Name) -> RFC_9110.Header.Field.Value? {
        headers[name]?.first
    }

    public func addingHeader(_ field: RFC_9110.Header.Field) -> Self {
        var copy = self
        copy.headers.append(field)
        return copy
    }

    public func removingHeaders(_ name: RFC_9110.Header.Field.Name) -> Self {
        var copy = self
        copy.headers.removeAll(named: name)
        return copy
    }
}

extension RFC_9110.Response: CustomStringConvertible {

    public var description: String {
        var result = status.description
        for header in headers {
            result += "\n\(header.description)"
        }
        if let body {
            result += "\n\n[Body: \(body.count) bytes]"
        }
        return result
    }
}

extension RFC_9110.Response: CustomDebugStringConvertible {

    public var debugDescription: String {
        let statusLine =
            if let reasonPhrase = status.reasonPhrase {
                "\(status.code) \(reasonPhrase)"
            } else {
                "\(status.code)"
            }

        return """
            RFC_9110.Response(
              status: \(statusLine)
              headers: \(headers.count) field\(headers.count == 1 ? "" : "s")
              body: \(body?.count ?? 0) bytes
            )
            """
    }
}

extension RFC_9110.Response {

    public static func ok(
        headers: RFC_9110.Headers = [],
        body: [Byte]? = nil
    ) -> Self {
        Self(status: .ok, headers: headers, body: body)
    }

    public static func created(
        location: String? = nil,
        headers: RFC_9110.Headers = [],
        body: [Byte]? = nil
    ) throws(RFC_9110.Header.Field.Error) -> Self {
        var responseHeaders = headers
        if let location {
            responseHeaders.append(try RFC_9110.Header.Field(name: "Location", value: location))
        }
        return Self(status: .created, headers: responseHeaders, body: body)
    }

    public static func noContent(
        headers: RFC_9110.Headers = []
    ) -> Self {
        Self(status: .noContent, headers: headers, body: nil)
    }

    public static func movedPermanently(
        to location: String,
        headers: RFC_9110.Headers = []
    ) throws(RFC_9110.Header.Field.Error) -> Self {
        var responseHeaders = headers
        responseHeaders.append(try RFC_9110.Header.Field(name: "Location", value: location))
        return Self(status: .movedPermanently, headers: responseHeaders, body: nil)
    }

    public static func found(
        at location: String,
        headers: RFC_9110.Headers = []
    ) throws(RFC_9110.Header.Field.Error) -> Self {
        var responseHeaders = headers
        responseHeaders.append(try RFC_9110.Header.Field(name: "Location", value: location))
        return Self(status: .found, headers: responseHeaders, body: nil)
    }

    public static func seeOther(
        at location: String,
        headers: RFC_9110.Headers = []
    ) throws(RFC_9110.Header.Field.Error) -> Self {
        var responseHeaders = headers
        responseHeaders.append(try RFC_9110.Header.Field(name: "Location", value: location))
        return Self(status: .seeOther, headers: responseHeaders, body: nil)
    }

    public static func notModified(
        headers: RFC_9110.Headers = []
    ) -> Self {
        Self(status: .notModified, headers: headers, body: nil)
    }

    public static func badRequest(
        headers: RFC_9110.Headers = [],
        body: [Byte]? = nil
    ) -> Self {
        Self(status: .badRequest, headers: headers, body: body)
    }

    public static func unauthorized(
        wwwAuthenticate: String,
        headers: RFC_9110.Headers = [],
        body: [Byte]? = nil
    ) throws(RFC_9110.Header.Field.Error) -> Self {
        var responseHeaders = headers
        responseHeaders.append(
            try RFC_9110.Header.Field(name: "WWW-Authenticate", value: wwwAuthenticate)
        )
        return Self(status: .unauthorized, headers: responseHeaders, body: body)
    }

    public static func forbidden(
        headers: RFC_9110.Headers = [],
        body: [Byte]? = nil
    ) -> Self {
        Self(status: .forbidden, headers: headers, body: body)
    }

    public static func notFound(
        headers: RFC_9110.Headers = [],
        body: [Byte]? = nil
    ) -> Self {
        Self(status: .notFound, headers: headers, body: body)
    }

    public static func internalServerError(
        headers: RFC_9110.Headers = [],
        body: [Byte]? = nil
    ) -> Self {
        Self(status: .internalServerError, headers: headers, body: body)
    }

    public static func serviceUnavailable(
        retryAfter: String? = nil,
        headers: RFC_9110.Headers = [],
        body: [Byte]? = nil
    ) throws(RFC_9110.Header.Field.Error) -> Self {
        var responseHeaders = headers
        if let retryAfter {
            responseHeaders.append(
                try RFC_9110.Header.Field(name: "Retry-After", value: retryAfter)
            )
        }
        return Self(status: .serviceUnavailable, headers: responseHeaders, body: body)
    }
}

public import Byte_Primitives
public import RFC_3986

extension RFC_9110 {

    public struct Request: Sendable, Equatable, Hashable, Codable {

        public var method: RFC_9110.Method

        public var target: Target

        public var headers: RFC_9110.Headers

        public var body: [Byte]?

        public init(
            method: RFC_9110.Method,
            target: Target,
            headers: RFC_9110.Headers = [],
            body: [Byte]? = nil
        ) {
            self.method = method
            self.target = target
            self.headers = headers
            self.body = body
        }
    }
}

extension RFC_9110.Request {

    public init(
        method: RFC_9110.Method = .get,
        scheme: RFC_3986.URI.Scheme? = nil,
        userinfo: RFC_3986.URI.Userinfo? = nil,
        host: RFC_3986.URI.Host? = nil,
        port: RFC_3986.URI.Port? = nil,
        path: RFC_3986.URI.Path? = nil,
        query: RFC_3986.URI.Query? = nil,
        headers: RFC_9110.Headers = [],
        body: [Byte]? = nil
    ) {

        let target: Target

        let effectivePath = path ?? (try! RFC_3986.URI.Path("/"))

        if let scheme, let host {

            let authority = RFC_3986.URI.Authority(
                userinfo: userinfo,
                host: host,
                port: port
            )

            let uri = RFC_3986.URI(
                scheme: scheme,
                authority: authority,
                path: effectivePath,
                query: query,
                fragment: nil
            )

            target = .absolute(uri)
        } else {

            target = .origin(path: effectivePath, query: query)
        }

        self.init(
            method: method,
            target: target,
            headers: headers,
            body: body
        )
    }
}

extension RFC_9110.Request {

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

extension RFC_9110.Request {

    public var path: RFC_3986.URI.Path? {
        target.path
    }

    public var query: RFC_3986.URI.Query? {
        target.query
    }

    public var scheme: RFC_3986.URI.Scheme? {
        guard case .absolute(let uri) = target else {
            return nil
        }
        return uri.scheme
    }

    public var authority: RFC_3986.URI.Authority? {
        switch target {
        case .absolute(let uri):

            guard let host = uri.host else {
                return nil
            }
            return RFC_3986.URI.Authority(
                userinfo: uri.userinfo,
                host: host,
                port: uri.port
            )

        case .authority(let authority):
            return authority

        case .origin, .asterisk:
            return nil
        }
    }

    public var host: RFC_3986.URI.Host? {
        authority?.host
    }
}

extension RFC_9110.Request {

    public func validate() throws(Error) {

        switch target {
        case .authority:

            guard method == .connect else {
                throw Error.invalidMethodForTarget(
                    method: method,
                    target: target,
                    reason:
                        "authority-form can only be used with CONNECT method (RFC 9110 §7.1)"
                )
            }

        case .asterisk:

            guard method == .options else {
                throw Error.invalidMethodForTarget(
                    method: method,
                    target: target,
                    reason: "asterisk-form can only be used with OPTIONS method (RFC 9110 §7.1)"
                )
            }

        case .origin, .absolute:

            if method == .connect {
                throw Error.invalidMethodForTarget(
                    method: method,
                    target: target,
                    reason:
                        "CONNECT method can only be used with authority-form (RFC 9110 §7.1)"
                )
            }
        }

    }
}

extension RFC_9110.Request: CustomStringConvertible {

    public var description: String {
        var result = "\(method.rawValue) \(target.rawValue)"
        for header in headers {
            result += "\n\(header.description)"
        }
        if let body {
            result += "\n\n[Body: \(body.count) bytes]"
        }
        return result
    }
}

extension RFC_9110.Request: CustomDebugStringConvertible {

    public var debugDescription: String {
        """
        RFC_9110.Request(
          method: \(method.rawValue)
          target: \(target.rawValue)
          headers: \(headers.count) field\(headers.count == 1 ? "" : "s")
          body: \(body?.count ?? 0) bytes
        )
        """
    }
}

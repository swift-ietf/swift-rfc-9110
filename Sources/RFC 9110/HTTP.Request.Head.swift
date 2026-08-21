public import Byte_Primitives

extension RFC_9110.Request {

    public struct Head: Sendable, Equatable, Hashable, Codable {

        public var method: RFC_9110.Method

        public var target: Target

        public var headers: RFC_9110.Headers

        public init(
            method: RFC_9110.Method,
            target: Target,
            headers: RFC_9110.Headers = []
        ) {
            self.method = method
            self.target = target
            self.headers = headers
        }
    }

    public var head: Head {
        .init(method: method, target: target, headers: headers)
    }

    public init(head: Head, body: [Byte]? = nil) {
        self.init(
            method: head.method,
            target: head.target,
            headers: head.headers,
            body: body
        )
    }
}

public import Byte_Primitives

extension RFC_9110.Response {

    public struct Head: Sendable, Equatable, Hashable, Codable {

        public var status: RFC_9110.Status

        public var headers: RFC_9110.Headers

        public init(
            status: RFC_9110.Status,
            headers: RFC_9110.Headers = []
        ) {
            self.status = status
            self.headers = headers
        }
    }

    public var head: Head {
        .init(status: status, headers: headers)
    }

    public init(head: Head, body: [Byte]? = nil) {
        self.init(status: head.status, headers: head.headers, body: body)
    }
}

extension RFC_9110.Message {
    public struct Response<Content> {
        public var status: RFC_9110.Status
        public var reason: RFC_9110.Status.Reason?
        public var headers: RFC_9110.Message.Headers
        public var content: Content?
        public var trailers: RFC_9110.Message.Trailers

        public init(
            status: RFC_9110.Status,
            reason: RFC_9110.Status.Reason? = nil,
            headers: RFC_9110.Message.Headers = [],
            content: Content? = nil,
            trailers: RFC_9110.Message.Trailers = []
        ) {
            self.status = status
            self.reason = reason
            self.headers = headers
            self.content = content
            self.trailers = trailers
        }
    }
}

extension RFC_9110.Message.Response: Equatable where Content: Equatable {}
extension RFC_9110.Message.Response: Hashable where Content: Hashable {}

extension RFC_9110.Message {
    public struct Request<Content> {
        public var method: RFC_9110.Method
        public var target: RFC_9110.Target
        public var headers: RFC_9110.Message.Headers
        public var content: Content?
        public var trailers: RFC_9110.Message.Trailers

        public init(
            method: RFC_9110.Method,
            target: RFC_9110.Target,
            headers: RFC_9110.Message.Headers = [],
            content: Content? = nil,
            trailers: RFC_9110.Message.Trailers = []
        ) {
            self.method = method
            self.target = target
            self.headers = headers
            self.content = content
            self.trailers = trailers
        }
    }
}

extension RFC_9110.Message.Request: Equatable where Content: Equatable {}
extension RFC_9110.Message.Request: Hashable where Content: Hashable {}

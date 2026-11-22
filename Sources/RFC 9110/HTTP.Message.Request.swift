extension IETF.RFC.`9110`.Message {
    public struct Request<Content> {
        public var method: IETF.RFC.`9110`.Method
        public var target: IETF.RFC.`9110`.Target
        public var headers: IETF.RFC.`9110`.Message.Headers
        public var content: Content?
        public var trailers: IETF.RFC.`9110`.Message.Trailers

        public init(
            method: IETF.RFC.`9110`.Method,
            target: IETF.RFC.`9110`.Target,
            headers: IETF.RFC.`9110`.Message.Headers = [],
            content: Content? = nil,
            trailers: IETF.RFC.`9110`.Message.Trailers = []
        ) {
            self.method = method
            self.target = target
            self.headers = headers
            self.content = content
            self.trailers = trailers
        }
    }
}

extension IETF.RFC.`9110`.Message.Request: Equatable where Content: Equatable {}
extension IETF.RFC.`9110`.Message.Request: Hashable where Content: Hashable {}
extension IETF.RFC.`9110`.Message.Request: Sendable where Content: Sendable {}

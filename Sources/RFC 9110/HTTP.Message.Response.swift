extension IETF.RFC.`9110`.Message {
    public struct Response<Content> {
        public var status: IETF.RFC.`9110`.Status
        public var reason: IETF.RFC.`9110`.Status.Reason?
        public var headers: IETF.RFC.`9110`.Message.Headers
        public var content: Content?
        public var trailers: IETF.RFC.`9110`.Message.Trailers

        public init(
            status: IETF.RFC.`9110`.Status,
            reason: IETF.RFC.`9110`.Status.Reason? = nil,
            headers: IETF.RFC.`9110`.Message.Headers = [],
            content: Content? = nil,
            trailers: IETF.RFC.`9110`.Message.Trailers = []
        ) {
            self.status = status
            self.reason = reason
            self.headers = headers
            self.content = content
            self.trailers = trailers
        }
    }
}

extension IETF.RFC.`9110`.Message.Response: Equatable where Content: Equatable {}
extension IETF.RFC.`9110`.Message.Response: Hashable where Content: Hashable {}
extension IETF.RFC.`9110`.Message.Response: Sendable where Content: Sendable {}

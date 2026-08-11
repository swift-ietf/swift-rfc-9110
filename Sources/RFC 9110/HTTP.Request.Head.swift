// HTTP.Request.Head.swift
// swift-rfc-9110
//
// RFC 9110 Section 6: Message Abstraction
// https://www.rfc-editor.org/rfc/rfc9110.html#section-6

public import Byte_Primitives

extension RFC_9110.Request {
    /// The body-free metadata of an HTTP request message.
    ///
    /// A request head contains the request method, request target, and header
    /// fields. It deliberately carries no message body or transport state.
    ///
    /// Use ``RFC_9110/Request/head`` to project an existing request, and
    /// ``RFC_9110/Request/init(head:body:)`` to construct a request from a head.
    public struct Head: Sendable, Equatable, Hashable, Codable {
        /// The method to apply to the target resource.
        public var method: RFC_9110.Method

        /// The resource to which the method applies.
        public var target: Target

        /// The request's header fields.
        public var headers: RFC_9110.Headers

        /// Creates a body-free HTTP request head.
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

    /// The body-free metadata projected from this request.
    public var head: Head {
        .init(method: method, target: target, headers: headers)
    }

    /// Creates a request by combining body-free metadata with an optional body.
    public init(head: Head, body: [Byte]? = nil) {
        self.init(
            method: head.method,
            target: head.target,
            headers: head.headers,
            body: body
        )
    }
}

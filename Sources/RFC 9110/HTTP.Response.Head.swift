// HTTP.Response.Head.swift
// swift-rfc-9110
//
// RFC 9110 Section 6: Message Abstraction
// https://www.rfc-editor.org/rfc/rfc9110.html#section-6

public import Byte_Primitives

extension RFC_9110.Response {
    /// The body-free metadata of an HTTP response message.
    ///
    /// A response head contains the status and header fields. It deliberately
    /// carries no message body or transport state.
    ///
    /// Use ``RFC_9110/Response/head`` to project an existing response, and
    /// ``RFC_9110/Response/init(head:body:)`` to construct a response from a head.
    public struct Head: Sendable, Equatable, Hashable, Codable {
        /// The status returned by the origin server.
        public var status: RFC_9110.Status

        /// The response's header fields.
        public var headers: RFC_9110.Headers

        /// Creates a body-free HTTP response head.
        public init(
            status: RFC_9110.Status,
            headers: RFC_9110.Headers = []
        ) {
            self.status = status
            self.headers = headers
        }
    }

    /// The body-free metadata projected from this response.
    public var head: Head {
        .init(status: status, headers: headers)
    }

    /// Creates a response by combining body-free metadata with an optional body.
    public init(head: Head, body: [Byte]? = nil) {
        self.init(status: head.status, headers: head.headers, body: body)
    }
}

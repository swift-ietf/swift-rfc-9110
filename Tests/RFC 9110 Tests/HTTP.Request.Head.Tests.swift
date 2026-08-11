import Byte_Primitives
import Testing

@testable import RFC_9110

@Suite
struct `HTTP.Request.Head Tests` {
    @Test
    func `Head preserves request metadata`() throws {
        let headers: HTTP.Headers = [
            try .init(name: "Accept", value: "application/json")
        ]
        let head = HTTP.Request.Head(
            method: .get,
            target: .origin(path: try .init("/messages"), query: nil),
            headers: headers
        )

        #expect(head.method == .get)
        #expect(head.target == .origin(path: try .init("/messages"), query: nil))
        #expect(head.headers == headers)
    }

    @Test
    func `Head projects and reconstructs a request`() throws {
        let body = Array("payload".utf8).map { Byte($0) }
        let request = HTTP.Request(
            method: .post,
            target: .origin(path: try .init("/messages"), query: nil),
            body: body
        )

        let reconstructed = HTTP.Request(head: request.head, body: request.body)

        #expect(reconstructed == request)
    }
}

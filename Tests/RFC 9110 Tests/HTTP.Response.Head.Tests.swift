import Byte_Primitives
import Testing

@testable import RFC_9110

@Suite
struct `HTTP.Response.Head Tests` {
    @Test
    func `Head preserves response metadata`() throws {
        let headers: HTTP.Headers = [
            try .init(name: "Content-Type", value: "application/json")
        ]
        let head = HTTP.Response.Head(status: .ok, headers: headers)

        #expect(head.status == .ok)
        #expect(head.headers == headers)
    }

    @Test
    func `Head projects and reconstructs a response`() {
        let body = Array("payload".utf8).map { Byte($0) }
        let response = HTTP.Response(status: .ok, body: body)

        let reconstructed = HTTP.Response(head: response.head, body: response.body)

        #expect(reconstructed == response)
    }
}

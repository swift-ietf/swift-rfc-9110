import RFC_9110
import Testing

@Suite
struct `HTTP.Message.Request Tests` {
    @Test
    func `Request retains semantic control and content`() throws {
        let uri = try RFC_3986.URI("https://example.com/greeting?name=Blob")
        let request = HTTP.Message.Request<String>(
            method: .get,
            target: .resource(uri),
            content: "hello"
        )

        #expect(request.method == .get)
        #expect(request.target == .resource(uri))
        #expect(request.content == "hello")
    }
}

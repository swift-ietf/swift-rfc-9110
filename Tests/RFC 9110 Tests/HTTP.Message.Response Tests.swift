import RFC_9110
import Testing

@Suite
struct `HTTP.Message.Response Tests` {
    @Test
    func `Response retains semantic control and content`() throws {
        let response = HTTP.Message.Response<String>(
            status: .ok,
            content: "hello"
        )

        #expect(response.status == .ok)
        #expect(response.content == "hello")
    }
}

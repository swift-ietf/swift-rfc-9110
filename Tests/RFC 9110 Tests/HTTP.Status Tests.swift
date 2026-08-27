import RFC_9110
import Testing

@Suite
struct `HTTP.Status Tests` {
    @Test
    func `Status classes follow the first digit`() {
        #expect(HTTP.Status.ok.isSuccessful)
        #expect(HTTP.Status.notFound.isClientError)
        #expect(HTTP.Status.serviceUnavailable.isServerError)
    }

    @Test
    func `Status identity is its code`() {
        #expect(HTTP.Status(200) == .ok)
        #expect(HTTP.Status.ok.description == "200")
    }
}

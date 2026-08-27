import RFC_9110
import Testing

@Suite
struct `HTTP.Method Tests` {
    @Test
    func `Standard methods retain their semantics`() {
        #expect(HTTP.Method.get.isSafe)
        #expect(HTTP.Method.get.isIdempotent)
        #expect(!HTTP.Method.post.isSafe)
        #expect(HTTP.Method(rawValue: "PATCH") == .patch)
    }
}

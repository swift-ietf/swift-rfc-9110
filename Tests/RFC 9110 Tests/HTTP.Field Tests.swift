import RFC_9110
import Testing

@Suite
struct `HTTP.Field Tests` {
    @Test
    func `Names compare without case`() throws {
        #expect(try HTTP.Field.Name("Content-Type") == HTTP.Field.Name("content-type"))
    }

    @Test
    func `A field retains its name and value`() throws {
        let field = try HTTP.Field(name: "Content-Type", value: "text/plain")
        #expect(field.name == .contentType)
        #expect(field.value.description == "text/plain")
    }

    @Test
    func `Headers preserve field line order`() throws {
        let first = try HTTP.Field(name: "X-A", value: "1")
        let second = try HTTP.Field(name: "X-B", value: "2")
        let third = try HTTP.Field(name: "X-A", value: "3")
        let headers: HTTP.Message.Headers = [first, second, third]

        #expect(Array(headers) == [first, second, third])
        #expect(headers[try .init("X-A")].map(\.description) == ["1", "3"])
    }

    @Test
    func `Trailers remain distinct from headers`() throws {
        let field = try HTTP.Field(name: "Digest", value: "value")
        let trailers: HTTP.Message.Trailers = [field]
        #expect(Array(trailers) == [field])
    }
}

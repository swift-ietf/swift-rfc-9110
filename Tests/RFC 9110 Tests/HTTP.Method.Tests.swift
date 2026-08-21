import Foundation
import Testing

@testable import RFC_9110

@Suite
struct `HTTP.Method Tests` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}

    @Test
    func `Standard methods have correct properties`() async throws {

        #expect(HTTP.Method.get.isSafe == true)
        #expect(HTTP.Method.get.isIdempotent == true)
        #expect(HTTP.Method.get.isCacheable == true)

        #expect(HTTP.Method.post.isSafe == false)
        #expect(HTTP.Method.post.isIdempotent == false)
        #expect(HTTP.Method.post.isCacheable == true)

        #expect(HTTP.Method.put.isSafe == false)
        #expect(HTTP.Method.put.isIdempotent == true)
        #expect(HTTP.Method.put.isCacheable == false)

        #expect(HTTP.Method.delete.isSafe == false)
        #expect(HTTP.Method.delete.isIdempotent == true)
        #expect(HTTP.Method.delete.isCacheable == false)

        #expect(HTTP.Method.head.isSafe == true)
        #expect(HTTP.Method.head.isIdempotent == true)
        #expect(HTTP.Method.head.isCacheable == true)

        #expect(HTTP.Method.options.isSafe == true)
        #expect(HTTP.Method.options.isIdempotent == true)
        #expect(HTTP.Method.options.isCacheable == false)

        #expect(HTTP.Method.trace.isSafe == true)
        #expect(HTTP.Method.trace.isIdempotent == true)
        #expect(HTTP.Method.trace.isCacheable == false)

        #expect(HTTP.Method.connect.isSafe == false)
        #expect(HTTP.Method.connect.isIdempotent == false)
        #expect(HTTP.Method.connect.isCacheable == false)

        #expect(HTTP.Method.patch.isSafe == false)
        #expect(HTTP.Method.patch.isIdempotent == false)
        #expect(HTTP.Method.patch.isCacheable == false)
    }

    @Test
    func `Method equality based on rawValue`() async throws {
        #expect(
            HTTP.Method.get
                == HTTP.Method("GET", isSafe: true, isIdempotent: true, isCacheable: true)
        )
        #expect(HTTP.Method.post != HTTP.Method.get)
    }

    @Test
    func `Method hashable`() async throws {
        var set: Set<HTTP.Method> = []
        set.insert(.get)
        set.insert(.post)
        set.insert(.get)

        #expect(set.count == 2)
        #expect(set.contains(.get))
        #expect(set.contains(.post))
    }

    @Test
    func `Method codable`() async throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        let encoded = try encoder.encode(HTTP.Method.get)
        let decoded = try decoder.decode(HTTP.Method.self, from: encoded)

        #expect(decoded == .get)
        #expect(decoded.isSafe == true)
    }

    @Test
    func `Custom method`() async throws {
        let custom = HTTP.Method(rawValue: "CUSTOM")

        #expect(custom.rawValue == "CUSTOM")
        #expect(custom.isSafe == false)
        #expect(custom.isIdempotent == false)
        #expect(custom.isCacheable == false)
    }

    @Test
    func `String literal`() async throws {
        let method: HTTP.Method = "CUSTOM"

        #expect(method.rawValue == "CUSTOM")
    }

    @Test
    func `Description`() async throws {
        #expect(HTTP.Method.get.description == "GET")
        #expect(HTTP.Method.post.description == "POST")
    }
}

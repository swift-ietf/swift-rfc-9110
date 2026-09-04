import Foundation
import Testing

@testable import RFC_9110

@Suite
struct `HTTP.Negotiation.Vary Tests` {

    @Test
    func `Vary creation with field names`() async throws {
        let vary = HTTP.Negotiation.Vary(fieldNames: ["Accept-Encoding", "Accept-Language"])

        #expect(vary.fieldNames == ["accept-encoding", "accept-language"])
        #expect(!vary.variesOnAllAspects)
    }

    @Test
    func `Vary.all - varies on all aspects`() async throws {
        let vary = HTTP.Negotiation.Vary.all

        #expect(vary.fieldNames.isEmpty)
        #expect(vary.variesOnAllAspects)
    }

    @Test
    func `Header value - field names`() async throws {
        let vary = HTTP.Negotiation.Vary(fieldNames: ["Accept-Encoding", "Accept-Language"])

        #expect(vary.headerValue == "accept-encoding, accept-language")
    }

    @Test
    func `Header value - all aspects`() async throws {
        let vary = HTTP.Negotiation.Vary.all

        #expect(vary.headerValue == "*")
    }

    @Test
    func `includes - field name present`() async throws {
        let vary = HTTP.Negotiation.Vary(fieldNames: ["Accept-Encoding", "User-Agent"])

        #expect(vary.includes("Accept-Encoding"))
        #expect(vary.includes("accept-encoding"))
        #expect(vary.includes("User-Agent"))
    }

    @Test
    func `includes - field name absent`() async throws {
        let vary = HTTP.Negotiation.Vary(fieldNames: ["Accept-Encoding"])

        #expect(!vary.includes("Cookie"))
        #expect(!vary.includes("User-Agent"))
    }

    @Test
    func `includes - all aspects`() async throws {
        let vary = HTTP.Negotiation.Vary.all

        #expect(vary.includes("Accept-Encoding"))
        #expect(vary.includes("Cookie"))
        #expect(vary.includes("anything"))
    }

    @Test
    func `matches - same headers`() async throws {
        let vary = HTTP.Negotiation.Vary(fieldNames: ["Accept-Encoding"])

        let result = vary.matches(
            requestHeaders: ["accept-encoding": "gzip"],
            cachedRequestHeaders: ["accept-encoding": "gzip"]
        )

        #expect(result == true)
    }

    @Test
    func `matches - different headers`() async throws {
        let vary = HTTP.Negotiation.Vary(fieldNames: ["Accept-Encoding"])

        let result = vary.matches(
            requestHeaders: ["accept-encoding": "br"],
            cachedRequestHeaders: ["accept-encoding": "gzip"]
        )

        #expect(result == false)
    }

    @Test
    func `matches - all aspects never matches`() async throws {
        let vary = HTTP.Negotiation.Vary.all

        let result = vary.matches(
            requestHeaders: ["accept-encoding": "gzip"],
            cachedRequestHeaders: ["accept-encoding": "gzip"]
        )

        #expect(result == false)
    }

    @Test
    func `matches - multiple fields`() async throws {
        let vary = HTTP.Negotiation.Vary(fieldNames: ["Accept-Encoding", "User-Agent"])

        let result1 = vary.matches(
            requestHeaders: ["accept-encoding": "gzip", "user-agent": "Mozilla"],
            cachedRequestHeaders: ["accept-encoding": "gzip", "user-agent": "Mozilla"]
        )
        #expect(result1 == true)

        let result2 = vary.matches(
            requestHeaders: ["accept-encoding": "gzip", "user-agent": "Chrome"],
            cachedRequestHeaders: ["accept-encoding": "gzip", "user-agent": "Mozilla"]
        )
        #expect(result2 == false)
    }

    @Test
    func `Equality`() async throws {
        let vary1 = HTTP.Negotiation.Vary(fieldNames: ["Accept-Encoding"])
        let vary2 = HTTP.Negotiation.Vary(fieldNames: ["Accept-Encoding"])
        let vary3 = HTTP.Negotiation.Vary(fieldNames: ["User-Agent"])
        let vary4 = HTTP.Negotiation.Vary.all

        #expect(vary1 == vary2)
        #expect(vary1 != vary3)
        #expect(vary1 != vary4)
    }

    @Test
    func `Hashable`() async throws {
        var set: Set<HTTP.Negotiation.Vary> = []

        set.insert(HTTP.Negotiation.Vary(fieldNames: ["Accept-Encoding"]))
        set.insert(HTTP.Negotiation.Vary(fieldNames: ["Accept-Encoding"]))
        set.insert(HTTP.Negotiation.Vary(fieldNames: ["User-Agent"]))
        set.insert(HTTP.Negotiation.Vary.all)

        #expect(set.count == 3)
    }

    @Test
    func `Codable`() async throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        let vary = HTTP.Negotiation.Vary(fieldNames: ["Accept-Encoding", "User-Agent"])
        let encoded = try encoder.encode(vary)
        let decoded = try decoder.decode(HTTP.Negotiation.Vary.self, from: encoded)

        #expect(decoded == vary)
    }

    @Test
    func `Description`() async throws {
        let vary = HTTP.Negotiation.Vary(fieldNames: ["Accept-Encoding"])

        #expect(vary.description == "accept-encoding")
    }

    @Test
    func `ExpressibleByArrayLiteral`() async throws {
        let vary: HTTP.Negotiation.Vary = ["Accept-Encoding", "User-Agent"]

        #expect(vary.fieldNames == ["accept-encoding", "user-agent"])
    }
}

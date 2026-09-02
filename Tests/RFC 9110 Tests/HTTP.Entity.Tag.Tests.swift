import Foundation
import Testing

@testable import RFC_9110

@Suite
struct `HTTP.Entity.Tag Tests` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}

    @Test
    func `Strong ETag creation`() async throws {
        let etag = HTTP.Entity.Tag.strong("686897696a7c876b7e")

        #expect(etag.value == "686897696a7c876b7e")
        #expect(etag.isWeak == false)
    }

    @Test
    func `Weak ETag creation`() async throws {
        let etag = HTTP.Entity.Tag.weak("686897696a7c876b7e")

        #expect(etag.value == "686897696a7c876b7e")
        #expect(etag.isWeak == true)
    }

    @Test
    func `Strong ETag header value`() async throws {
        let etag = HTTP.Entity.Tag.strong("abc123")

        #expect(etag.headerValue == "\"abc123\"")
    }

    @Test
    func `Weak ETag header value`() async throws {
        let etag = HTTP.Entity.Tag.weak("abc123")

        #expect(etag.headerValue == "W/\"abc123\"")
    }

    @Test
    func `Strong comparison - both strong and equal`() async throws {
        let etag1 = HTTP.Entity.Tag.strong("abc")
        let etag2 = HTTP.Entity.Tag.strong("abc")

        #expect(HTTP.Entity.Tag.strongCompare(etag1, etag2) == true)
    }

    @Test
    func `Strong comparison - both strong but different`() async throws {
        let etag1 = HTTP.Entity.Tag.strong("abc")
        let etag2 = HTTP.Entity.Tag.strong("xyz")

        #expect(HTTP.Entity.Tag.strongCompare(etag1, etag2) == false)
    }

    @Test
    func `Strong comparison - one weak`() async throws {
        let strong = HTTP.Entity.Tag.strong("abc")
        let weak = HTTP.Entity.Tag.weak("abc")

        #expect(HTTP.Entity.Tag.strongCompare(strong, weak) == false)
        #expect(HTTP.Entity.Tag.strongCompare(weak, strong) == false)
    }

    @Test
    func `Strong comparison - both weak`() async throws {
        let weak1 = HTTP.Entity.Tag.weak("abc")
        let weak2 = HTTP.Entity.Tag.weak("abc")

        #expect(HTTP.Entity.Tag.strongCompare(weak1, weak2) == false)
    }

    @Test
    func `Weak comparison - values match`() async throws {
        let strong = HTTP.Entity.Tag.strong("abc")
        let weak = HTTP.Entity.Tag.weak("abc")

        #expect(HTTP.Entity.Tag.weakCompare(strong, weak) == true)
        #expect(HTTP.Entity.Tag.weakCompare(weak, strong) == true)
    }

    @Test
    func `Weak comparison - values differ`() async throws {
        let etag1 = HTTP.Entity.Tag.strong("abc")
        let etag2 = HTTP.Entity.Tag.weak("xyz")

        #expect(HTTP.Entity.Tag.weakCompare(etag1, etag2) == false)
    }

    @Test
    func `Equality`() async throws {
        let strong1 = HTTP.Entity.Tag.strong("abc")
        let strong2 = HTTP.Entity.Tag.strong("abc")
        let weak1 = HTTP.Entity.Tag.weak("abc")
        let weak2 = HTTP.Entity.Tag.weak("abc")
        let different = HTTP.Entity.Tag.strong("xyz")

        #expect(strong1 == strong2)
        #expect(weak1 == weak2)
        #expect(strong1 != weak1)
        #expect(strong1 != different)
    }

    @Test
    func `Hashable`() async throws {
        var set: Set<HTTP.Entity.Tag> = []
        set.insert(.strong("abc"))
        set.insert(.strong("abc"))
        set.insert(.weak("abc"))
        set.insert(.strong("xyz"))

        #expect(set.count == 3)
    }

    @Test
    func `Description`() async throws {
        let strong = HTTP.Entity.Tag.strong("abc")
        #expect(strong.description == "\"abc\"")

        let weak = HTTP.Entity.Tag.weak("abc")
        #expect(weak.description == "W/\"abc\"")
    }
}

import Foundation
import Testing

@testable import RFC_9110

@Suite
struct `HTTP.Representation.Validator.EntityTag Tests` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}

    @Test
    func `Strong ETag creation`() async throws {
        let etag = HTTP.Representation.Validator.EntityTag.strong("686897696a7c876b7e")

        #expect(etag.value == "686897696a7c876b7e")
        #expect(etag.isWeak == false)
    }

    @Test
    func `Weak ETag creation`() async throws {
        let etag = HTTP.Representation.Validator.EntityTag.weak("686897696a7c876b7e")

        #expect(etag.value == "686897696a7c876b7e")
        #expect(etag.isWeak == true)
    }

    @Test
    func `Strong ETag header value`() async throws {
        let etag = HTTP.Representation.Validator.EntityTag.strong("abc123")

        #expect(etag.headerValue == "\"abc123\"")
    }

    @Test
    func `Weak ETag header value`() async throws {
        let etag = HTTP.Representation.Validator.EntityTag.weak("abc123")

        #expect(etag.headerValue == "W/\"abc123\"")
    }

    @Test
    func `Strong comparison - both strong and equal`() async throws {
        let etag1 = HTTP.Representation.Validator.EntityTag.strong("abc")
        let etag2 = HTTP.Representation.Validator.EntityTag.strong("abc")

        #expect(HTTP.Representation.Validator.EntityTag.strongCompare(etag1, etag2) == true)
    }

    @Test
    func `Strong comparison - both strong but different`() async throws {
        let etag1 = HTTP.Representation.Validator.EntityTag.strong("abc")
        let etag2 = HTTP.Representation.Validator.EntityTag.strong("xyz")

        #expect(HTTP.Representation.Validator.EntityTag.strongCompare(etag1, etag2) == false)
    }

    @Test
    func `Strong comparison - one weak`() async throws {
        let strong = HTTP.Representation.Validator.EntityTag.strong("abc")
        let weak = HTTP.Representation.Validator.EntityTag.weak("abc")

        #expect(HTTP.Representation.Validator.EntityTag.strongCompare(strong, weak) == false)
        #expect(HTTP.Representation.Validator.EntityTag.strongCompare(weak, strong) == false)
    }

    @Test
    func `Strong comparison - both weak`() async throws {
        let weak1 = HTTP.Representation.Validator.EntityTag.weak("abc")
        let weak2 = HTTP.Representation.Validator.EntityTag.weak("abc")

        #expect(HTTP.Representation.Validator.EntityTag.strongCompare(weak1, weak2) == false)
    }

    @Test
    func `Weak comparison - values match`() async throws {
        let strong = HTTP.Representation.Validator.EntityTag.strong("abc")
        let weak = HTTP.Representation.Validator.EntityTag.weak("abc")

        #expect(HTTP.Representation.Validator.EntityTag.weakCompare(strong, weak) == true)
        #expect(HTTP.Representation.Validator.EntityTag.weakCompare(weak, strong) == true)
    }

    @Test
    func `Weak comparison - values differ`() async throws {
        let etag1 = HTTP.Representation.Validator.EntityTag.strong("abc")
        let etag2 = HTTP.Representation.Validator.EntityTag.weak("xyz")

        #expect(HTTP.Representation.Validator.EntityTag.weakCompare(etag1, etag2) == false)
    }

    @Test
    func `Equality`() async throws {
        let strong1 = HTTP.Representation.Validator.EntityTag.strong("abc")
        let strong2 = HTTP.Representation.Validator.EntityTag.strong("abc")
        let weak1 = HTTP.Representation.Validator.EntityTag.weak("abc")
        let weak2 = HTTP.Representation.Validator.EntityTag.weak("abc")
        let different = HTTP.Representation.Validator.EntityTag.strong("xyz")

        #expect(strong1 == strong2)
        #expect(weak1 == weak2)
        #expect(strong1 != weak1)
        #expect(strong1 != different)
    }

    @Test
    func `Hashable`() async throws {
        var set: Set<HTTP.Representation.Validator.EntityTag> = []
        set.insert(.strong("abc"))
        set.insert(.strong("abc"))
        set.insert(.weak("abc"))
        set.insert(.strong("xyz"))

        #expect(set.count == 3)
    }

    @Test
    func `Description`() async throws {
        let strong = HTTP.Representation.Validator.EntityTag.strong("abc")
        #expect(strong.description == "\"abc\"")

        let weak = HTTP.Representation.Validator.EntityTag.weak("abc")
        #expect(weak.description == "W/\"abc\"")
    }
}

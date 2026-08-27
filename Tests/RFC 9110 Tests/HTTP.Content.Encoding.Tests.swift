import Foundation
import Testing

@testable import RFC_9110

@Suite
struct `HTTP.Message.Content.Encoding Tests` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}

    @Test
    func `Standard encodings`() async throws {
        #expect(HTTP.Message.Content.Encoding.gzip.value == "gzip")
        #expect(HTTP.Message.Content.Encoding.deflate.value == "deflate")
        #expect(HTTP.Message.Content.Encoding.compress.value == "compress")
        #expect(HTTP.Message.Content.Encoding.brotli.value == "br")
        #expect(HTTP.Message.Content.Encoding.identity.value == "identity")
    }

    @Test
    func `Custom encoding`() async throws {
        let custom = HTTP.Message.Content.Encoding("custom-encoding")

        #expect(custom.value == "custom-encoding")
    }

    @Test
    func `Case insensitive`() async throws {
        let upper = HTTP.Message.Content.Encoding("GZIP")
        let lower = HTTP.Message.Content.Encoding("gzip")

        #expect(upper.value == "gzip")
        #expect(lower.value == "gzip")
        #expect(upper == lower)
    }

    @Test
    func `Parse single encoding`() async throws {
        let encodings = HTTP.Message.Content.Encoding.parse("gzip")

        #expect(encodings.count == 1)
        #expect(encodings[0] == .gzip)
    }

    @Test
    func `Parse multiple encodings`() async throws {
        let encodings = HTTP.Message.Content.Encoding.parse("gzip, deflate")

        #expect(encodings.count == 2)
        #expect(encodings[0] == .gzip)
        #expect(encodings[1] == .deflate)
    }

    @Test
    func `Parse with whitespace`() async throws {
        let encodings = HTTP.Message.Content.Encoding.parse(" gzip ,  br  ")

        #expect(encodings.count == 2)
        #expect(encodings[0] == .gzip)
        #expect(encodings[1] == .brotli)
    }

    @Test
    func `Parse empty string`() async throws {
        let encodings = HTTP.Message.Content.Encoding.parse("")

        #expect(encodings.isEmpty)
    }

    @Test
    func `Format header - single`() async throws {
        let header = HTTP.Message.Content.Encoding.formatHeader([.gzip])

        #expect(header == "gzip")
    }

    @Test
    func `Format header - multiple`() async throws {
        let header = HTTP.Message.Content.Encoding.formatHeader([.gzip, .deflate, .brotli])

        #expect(header == "gzip, deflate, br")
    }

    @Test
    func `Format header - empty`() async throws {
        let header = HTTP.Message.Content.Encoding.formatHeader([])

        #expect(header.isEmpty)
    }

    @Test
    func `Equality`() async throws {
        let gzip1 = HTTP.Message.Content.Encoding.gzip
        let gzip2 = HTTP.Message.Content.Encoding("gzip")
        let br = HTTP.Message.Content.Encoding.brotli

        #expect(gzip1 == gzip2)
        #expect(gzip1 != br)
    }

    @Test
    func `Hashable`() async throws {
        var set: Set<HTTP.Message.Content.Encoding> = []
        set.insert(.gzip)
        set.insert(.gzip)
        set.insert(.brotli)

        #expect(set.count == 2)
    }

    @Test
    func `Codable`() async throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        let encoding = HTTP.Message.Content.Encoding.gzip
        let encoded = try encoder.encode(encoding)
        let decoded = try decoder.decode(HTTP.Message.Content.Encoding.self, from: encoded)

        #expect(decoded == encoding)
    }

    @Test
    func `Description`() async throws {
        #expect(HTTP.Message.Content.Encoding.gzip.description == "gzip")
        #expect(HTTP.Message.Content.Encoding.brotli.description == "br")
    }

    @Test
    func `String literal`() async throws {
        let gzip: HTTP.Message.Content.Encoding = "gzip"
        let custom: HTTP.Message.Content.Encoding = "custom"

        #expect(gzip == .gzip)
        #expect(custom.value == "custom")
    }
}

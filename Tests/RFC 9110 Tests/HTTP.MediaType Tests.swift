import Foundation
import Testing

@testable import RFC_9110

@Suite
struct `HTTP.MediaType Tests` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}

    @Test
    func `Media type creation`() async throws {
        let json = HTTP.MediaType("application", "json")

        #expect(json.type == "application")
        #expect(json.subtype == "json")
        #expect(json.parameters.isEmpty)
        #expect(json.value == "application/json")
    }

    @Test
    func `Media type with parameters`() async throws {
        let html = HTTP.MediaType("text", "html", parameters: ["charset": "utf-8"])

        #expect(html.type == "text")
        #expect(html.subtype == "html")
        #expect(html.parameters["charset"] == "utf-8")
        #expect(html.value == "text/html; charset=utf-8")
    }

    @Test
    func `Media type normalization`() async throws {
        let mt = HTTP.MediaType("TEXT", "HTML")

        #expect(mt.type == "text")
        #expect(mt.subtype == "html")
    }

    @Test
    func `Standard media types`() async throws {
        #expect(HTTP.MediaType.json.value == "application/json")
        #expect(HTTP.MediaType.html.value == "text/html")
        #expect(HTTP.MediaType.xml.value == "text/xml")
        #expect(HTTP.MediaType.plain.value == "text/plain")
        #expect(HTTP.MediaType.pdf.value == "application/pdf")
        #expect(HTTP.MediaType.png.value == "image/png")
        #expect(HTTP.MediaType.jpeg.value == "image/jpeg")
    }

    @Test
    func `Media type equality`() async throws {
        let json1 = HTTP.MediaType.json
        let json2 = HTTP.MediaType("application", "json")
        let html = HTTP.MediaType.html

        #expect(json1 == json2)
        #expect(json1 != html)
    }

    @Test
    func `Media type equality ignores parameters`() async throws {
        let html1 = HTTP.MediaType("text", "html")
        let html2 = HTTP.MediaType("text", "html", parameters: ["charset": "utf-8"])

        #expect(html1 == html2)
    }

    @Test
    func `Media type hashable`() async throws {
        var set: Set<HTTP.MediaType> = []
        set.insert(.json)
        set.insert(.html)
        set.insert(.json)

        #expect(set.count == 2)
    }

    @Test
    func `Media type description`() async throws {
        let json = HTTP.MediaType.json
        #expect(json.description == "application/json")

        let html = HTTP.MediaType("text", "html", parameters: ["charset": "utf-8"])
        #expect(html.description == "text/html; charset=utf-8")
    }

    @Test
    func `Media type value quotes parameter values that are not tokens`() async throws {
        let mediaType = HTTP.MediaType(
            "multipart",
            "form-data",
            parameters: ["boundary": "a b; c", "name": "say \"hi\" \\ bye", "charset": "utf-8"]
        )

        #expect(mediaType.value == #"multipart/form-data; boundary="a b; c"; charset=utf-8; name="say \"hi\" \\ bye""#)

        let parsed = try #require(HTTP.MediaType(parsing: mediaType.value))
        #expect(parsed == mediaType)
        #expect(parsed.parameters == mediaType.parameters)
    }

    @Test
    func `Media type with quoted parameters round-trips through Codable`() async throws {
        let mediaType = HTTP.MediaType("text", "plain", parameters: ["title": "x; y", "empty": ""])
        let data = try JSONEncoder().encode(mediaType)
        let decoded = try JSONDecoder().decode(HTTP.MediaType.self, from: data)

        #expect(decoded.parameters == mediaType.parameters)
    }
}

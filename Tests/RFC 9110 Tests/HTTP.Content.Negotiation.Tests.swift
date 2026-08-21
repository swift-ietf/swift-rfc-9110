import Foundation
import Testing

@testable import RFC_9110

@Suite
struct `HTTP.Content.Negotiation Tests` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}

    @Test
    func `Quality value creation`() async throws {
        let q1 = try #require(HTTP.Content.Negotiation.QualityValue(1000))
        #expect(q1.thousandths == 1000)

        let q0 = try #require(HTTP.Content.Negotiation.QualityValue(0))
        #expect(q0.thousandths == 0)

        let q05 = try #require(HTTP.Content.Negotiation.QualityValue(500))
        #expect(q05.thousandths == 500)
    }

    @Test
    func `Quality value rejects values outside the closed range`() async throws {
        #expect(HTTP.Content.Negotiation.QualityValue(1001) == nil)
        #expect(HTTP.Content.Negotiation.QualityValue(-1) == nil)
    }

    @Test
    func `Quality value parsing`() async throws {
        let q1 = HTTP.Content.Negotiation.QualityValue.parse("1.0")
        #expect(q1?.thousandths == 1000)

        let q05 = HTTP.Content.Negotiation.QualityValue.parse("0.5")
        #expect(q05?.thousandths == 500)

        #expect(HTTP.Content.Negotiation.QualityValue.parse("0.1234") == nil)
        #expect(HTTP.Content.Negotiation.QualityValue.parse("1.001") == nil)

        let invalid = HTTP.Content.Negotiation.QualityValue.parse("invalid")
        #expect(invalid == nil)
    }

    @Test
    func `Quality value comparison`() async throws {
        let q1 = try #require(HTTP.Content.Negotiation.QualityValue(1000))
        let q05 = try #require(HTTP.Content.Negotiation.QualityValue(500))
        let q0 = try #require(HTTP.Content.Negotiation.QualityValue(0))

        #expect(q1 > q05)
        #expect(q05 > q0)
        #expect(q0 < q1)
    }

    @Test
    func `Media type preference creation`() async throws {
        let pref = HTTP.Content.Negotiation.MediaTypePreference(
            mediaType: .json,
            quality: try #require(HTTP.Content.Negotiation.QualityValue(900))
        )

        #expect(pref.mediaType == .json)
        #expect(pref.quality.thousandths == 900)
    }

    @Test
    func `Media type preference default quality`() async throws {
        let pref = HTTP.Content.Negotiation.MediaTypePreference(mediaType: .json)

        #expect(pref.quality == .default)
        #expect(pref.quality.thousandths == 1000)
    }

    @Test
    func `Media type preference parsing - simple`() async throws {
        let prefs = HTTP.Content.Negotiation.MediaTypePreference.parse("application/json")

        #expect(prefs.count == 1)
        #expect(prefs[0].mediaType == .json)
        #expect(prefs[0].quality.thousandths == 1000)
    }

    @Test
    func `Media type preference parsing - with quality`() async throws {
        let prefs = HTTP.Content.Negotiation.MediaTypePreference.parse("application/json;q=0.9")

        #expect(prefs.count == 1)
        #expect(prefs[0].mediaType == .json)
        #expect(prefs[0].quality.thousandths == 900)
    }

    @Test
    func `Malformed explicit weights are rejected by every preference parser`() async throws {
        #expect(
            HTTP.Content.Negotiation.MediaTypePreference.parse("application/json;q=1.001")
                .isEmpty
        )
        #expect(
            HTTP.Content.Negotiation.CharsetPreference.parse("utf-8;q=0.1234").isEmpty
        )
        #expect(
            HTTP.Content.Negotiation.EncodingPreference.parse("gzip;q=invalid").isEmpty
        )
        #expect(
            HTTP.Content.Negotiation.LanguagePreference.parse("en;q=").isEmpty
        )
    }

    @Test
    func `Media type preference parsing - multiple`() async throws {
        let prefs = HTTP.Content.Negotiation.MediaTypePreference.parse(
            "text/html, application/json;q=0.9, */*;q=0.1"
        )

        #expect(prefs.count == 3)

        #expect(prefs[0].mediaType == .html)
        #expect(prefs[0].quality.thousandths == 1000)

        #expect(prefs[1].mediaType == .json)
        #expect(prefs[1].quality.thousandths == 900)

        #expect(prefs[2].mediaType.type == "*")
        #expect(prefs[2].quality.thousandths == 100)
    }

    @Test
    func `Media type preference parsing - specificity`() async throws {

        let prefs = HTTP.Content.Negotiation.MediaTypePreference.parse(
            "*/*;q=0.5, application/*;q=0.5, application/json;q=0.5"
        )

        #expect(prefs.count == 3)

        #expect(prefs[0].mediaType == .json)
        #expect(prefs[1].mediaType.type == "application")
        #expect(prefs[1].mediaType.subtype == "*")
        #expect(prefs[2].mediaType.type == "*")
    }

    @Test
    func `Select media type - exact match`() async throws {
        let available = [HTTP.MediaType.json, HTTP.MediaType.xml]
        let selected = HTTP.Content.Negotiation.selectMediaType(
            from: available,
            acceptHeader: "application/json"
        )

        #expect(selected == .json)
    }

    @Test
    func `Select media type - quality preference`() async throws {
        let available = [HTTP.MediaType.json, HTTP.MediaType.xml]
        let selected = HTTP.Content.Negotiation.selectMediaType(
            from: available,
            acceptHeader: "application/xml;q=0.9, application/json;q=1.0"
        )

        #expect(selected == .json)
    }

    @Test
    func `Select media type - wildcard`() async throws {
        let available = [HTTP.MediaType.json, HTTP.MediaType.html]
        let selected = HTTP.Content.Negotiation.selectMediaType(
            from: available,
            acceptHeader: "text/*"
        )

        #expect(selected == .html)
    }

    @Test
    func `Select media type - wildcard all`() async throws {
        let available = [HTTP.MediaType.json, HTTP.MediaType.html]
        let selected = HTTP.Content.Negotiation.selectMediaType(
            from: available,
            acceptHeader: "*/*"
        )

        #expect(selected == .json)
    }

    @Test
    func `Select media type - no match`() async throws {
        let available = [HTTP.MediaType.json]
        let selected = HTTP.Content.Negotiation.selectMediaType(
            from: available,
            acceptHeader: "text/html"
        )

        #expect(selected == nil)
    }

    @Test
    func `Select media types - multiple`() async throws {
        let available = [HTTP.MediaType.json, HTTP.MediaType.xmlApp, HTTP.MediaType.html]
        let selected = HTTP.Content.Negotiation.selectMediaTypes(
            from: available,
            acceptHeader: "application/json;q=1.0, application/xml;q=0.9, text/html;q=0.5"
        )

        #expect(selected.count == 3)
        #expect(selected[0] == .json)
        #expect(selected[1] == .xmlApp)
        #expect(selected[2] == .html)
    }

    @Test
    func `Select media types - wildcard`() async throws {
        let available = [HTTP.MediaType.json, HTTP.MediaType.xml, HTTP.MediaType.html]
        let selected = HTTP.Content.Negotiation.selectMediaTypes(
            from: available,
            acceptHeader: "application/*;q=1.0, */*;q=0.1"
        )

        #expect(selected.count == 3)

        #expect(selected[0] == .json || selected[0] == .xml)
    }

    @Test
    func `Select media types - zero quality excluded`() async throws {
        let available = [HTTP.MediaType.json, HTTP.MediaType.html]
        let selected = HTTP.Content.Negotiation.selectMediaTypes(
            from: available,
            acceptHeader: "application/json;q=1.0, text/html;q=0"
        )

        #expect(selected.count == 1)
        #expect(selected[0] == .json)
    }

    @Test
    func `Quality value description`() async throws {
        let q1 = try #require(HTTP.Content.Negotiation.QualityValue(1000))
        #expect(q1.description == "1")

        let q09 = try #require(HTTP.Content.Negotiation.QualityValue(900))
        #expect(q09.description == "0.9")

        let q0 = try #require(HTTP.Content.Negotiation.QualityValue(0))
        #expect(q0.description == "0")
    }

    @Test
    func `Media type preference description`() async throws {
        let pref1 = HTTP.Content.Negotiation.MediaTypePreference(mediaType: .json)
        #expect(pref1.description == "application/json")

        let pref2 = HTTP.Content.Negotiation.MediaTypePreference(
            mediaType: .json,
            quality: try #require(HTTP.Content.Negotiation.QualityValue(900))
        )
        #expect(pref2.description.contains("application/json"))
        #expect(pref2.description.contains("q=0.9"))
    }
}

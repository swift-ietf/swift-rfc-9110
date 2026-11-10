import Foundation
import Testing

@testable import RFC_9110

@Suite
struct `HTTP.Negotiation Tests` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}

    @Test
    func `Quality value creation`() async throws {
        let q1 = try #require(HTTP.Negotiation.QualityValue(1000))
        #expect(q1.thousandths == 1000)

        let q0 = try #require(HTTP.Negotiation.QualityValue(0))
        #expect(q0.thousandths == 0)

        let q05 = try #require(HTTP.Negotiation.QualityValue(500))
        #expect(q05.thousandths == 500)
    }

    @Test
    func `Quality value rejects values outside the closed range`() async throws {
        #expect(HTTP.Negotiation.QualityValue(1001) == nil)
        #expect(HTTP.Negotiation.QualityValue(-1) == nil)
    }

    @Test
    func `Quality value comparison`() async throws {
        let q1 = try #require(HTTP.Negotiation.QualityValue(1000))
        let q05 = try #require(HTTP.Negotiation.QualityValue(500))
        let q0 = try #require(HTTP.Negotiation.QualityValue(0))

        #expect(q1 > q05)
        #expect(q05 > q0)
        #expect(q0 < q1)
    }

    @Test
    func `Media type preference creation`() async throws {
        let pref = HTTP.Negotiation.MediaTypePreference(
            mediaType: .json,
            quality: try #require(HTTP.Negotiation.QualityValue(900))
        )

        #expect(pref.mediaType == .json)
        #expect(pref.quality.thousandths == 900)
    }

    @Test
    func `Media type preference default quality`() async throws {
        let pref = HTTP.Negotiation.MediaTypePreference(mediaType: .json)

        #expect(pref.quality == .default)
        #expect(pref.quality.thousandths == 1000)
    }

    @Test
    func `Quality value description`() async throws {
        let q1 = try #require(HTTP.Negotiation.QualityValue(1000))
        #expect(q1.description == "1")

        let q09 = try #require(HTTP.Negotiation.QualityValue(900))
        #expect(q09.description == "0.9")

        let q0 = try #require(HTTP.Negotiation.QualityValue(0))
        #expect(q0.description == "0")
    }

    @Test
    func `Media type preference description`() async throws {
        let pref1 = HTTP.Negotiation.MediaTypePreference(mediaType: .json)
        #expect(pref1.description == "application/json")

        let pref2 = HTTP.Negotiation.MediaTypePreference(
            mediaType: .json,
            quality: try #require(HTTP.Negotiation.QualityValue(900))
        )
        #expect(pref2.description.contains("application/json"))
        #expect(pref2.description.contains("q=0.9"))
    }

    @Test
    func `Select media type skips zero quality preferences`() async throws {
        let refused = HTTP.Negotiation.MediaTypePreference(
            mediaType: .json,
            quality: try #require(HTTP.Negotiation.QualityValue(0))
        )
        let accepted = HTTP.Negotiation.MediaTypePreference(mediaType: .html)

        #expect(HTTP.Negotiation.selectMediaType(from: [.json], preferences: [refused]) == nil)
        #expect(HTTP.Negotiation.selectMediaType(from: [.json, .html], preferences: [refused, accepted]) == .html)
    }
}

extension `HTTP.Negotiation Tests` {
    @Suite
    struct `Best encoding` {
        let offered: [HTTP.Representation.Encoding] = [.gzip, .identity]

        func weighted(_ encoding: HTTP.Representation.Encoding, _ thousandths: Int) -> HTTP.Negotiation.EncodingPreference {
            HTTP.Negotiation.EncodingPreference(encoding: encoding, quality: HTTP.Negotiation.QualityValue(thousandths) ?? .default)
        }

        @Test
        func `a named offered encoding is chosen`() {
            #expect(HTTP.Negotiation.EncodingPreference.best(of: offered, accepting: [HTTP.Negotiation.EncodingPreference(encoding: .gzip)]) == .gzip)
        }

        @Test
        func `the wildcard accepts an encoding it does not name`() {
            #expect(HTTP.Negotiation.EncodingPreference.best(of: offered, accepting: [HTTP.Negotiation.EncodingPreference(encoding: "*")]) == .gzip)
        }

        @Test
        func `an encoding weighted zero is refused and identity is left`() {
            #expect(HTTP.Negotiation.EncodingPreference.best(of: offered, accepting: [weighted(.gzip, 0)]) == .identity)
        }

        @Test
        func `a named weight overrides the wildcard`() {
            #expect(HTTP.Negotiation.EncodingPreference.best(of: offered, accepting: [weighted("*", 500), weighted(.gzip, 0)]) == .identity)
        }

        @Test
        func `a named encoding with a lower weight still beats identity that is only acceptable by default`() {
            #expect(HTTP.Negotiation.EncodingPreference.best(of: offered, accepting: [weighted(.brotli, 1000), weighted(.gzip, 800)]) == .gzip)
        }

        @Test
        func `the higher weight wins between named encodings`() {
            let both: [HTTP.Representation.Encoding] = [.gzip, .brotli]
            #expect(HTTP.Negotiation.EncodingPreference.best(of: both, accepting: [weighted(.gzip, 500), weighted(.brotli, 900)]) == .brotli)
        }

        @Test
        func `an encoding the request does not name is not chosen`() {
            #expect(HTTP.Negotiation.EncodingPreference.best(of: offered, accepting: [HTTP.Negotiation.EncodingPreference(encoding: .brotli)]) == .identity)
            #expect(HTTP.Negotiation.EncodingPreference.best(of: [.gzip], accepting: [HTTP.Negotiation.EncodingPreference(encoding: .brotli)]) == nil)
        }

        @Test
        func `identity excluded by the wildcard leaves nothing`() {
            #expect(HTTP.Negotiation.EncodingPreference.best(of: [.identity], accepting: [weighted("*", 0)]) == nil)
        }

        @Test
        func `no preferences leave identity only`() {
            #expect(HTTP.Negotiation.EncodingPreference.best(of: offered, accepting: []) == .identity)
        }
    }
}

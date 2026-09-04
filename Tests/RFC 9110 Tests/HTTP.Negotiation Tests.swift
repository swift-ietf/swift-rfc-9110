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
}

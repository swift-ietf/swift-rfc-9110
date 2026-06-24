import Foundation
// HTTP.Date.Tests.swift
// swift-rfc-9110

import RFC_5322
import Testing

@testable import RFC_9110

@Suite
struct `HTTP.Date Tests` {

    @Test
    func `Date creation`() async throws {
        let timestamp = 784_111_777  // Sun, 06 Nov 1994 08:49:37 GMT
        let httpDate = HTTP.Date(secondsSinceEpoch: timestamp)

        #expect(httpDate.secondsSinceEpoch == timestamp)
    }

    @Test
    func `Header value format - IMF-fixdate`() async throws {
        let httpDate = HTTP.Date(secondsSinceEpoch: 784_111_777)  // Sun, 06 Nov 1994 08:49:37 GMT

        let field = HTTP.Header.Field(dateTime: httpDate)
        let headerValue = field.value.rawValue

        // IMF-fixdate per RFC 9110 §5.6.7 (literal "GMT", never the RFC 5322 "+0000")
        #expect(headerValue == "Sun, 06 Nov 1994 08:49:37 GMT")
        #expect(headerValue.contains("GMT"))
        #expect(!headerValue.contains("+0000"))
    }

    @Test
    func `Parse IMF-fixdate format`() async throws {
        let field = try HTTP.Header.Field(name: "Date", value: "Sun, 06 Nov 1994 08:49:37 GMT")
        let parsed = RFC_5322.DateTime(field)

        #expect(parsed != nil)

        let expectedTimestamp = 784_111_777
        let diff = abs(parsed!.secondsSinceEpoch - expectedTimestamp)
        #expect(diff < 1)  // Within 1 second
    }

    @Test
    func `Parse RFC 850 format (obsolete)`() async throws {
        // RFC 9110 §5.6.7: recipients MUST accept the obsolete RFC 850 format
        let field = try HTTP.Header.Field(name: "Date", value: "Sunday, 06-Nov-94 08:49:37 GMT")
        let parsed = RFC_5322.DateTime(field)

        #expect(parsed != nil)

        let expectedTimestamp = 784_111_777
        #expect(abs(parsed!.secondsSinceEpoch - expectedTimestamp) < 1)
    }

    @Test
    func `Parse asctime format (obsolete)`() async throws {
        // RFC 9110 §5.6.7: recipients MUST accept the obsolete asctime format
        let field = try HTTP.Header.Field(name: "Date", value: "Sun Nov  6 08:49:37 1994")
        let parsed = RFC_5322.DateTime(field)

        #expect(parsed != nil)

        let expectedTimestamp = 784_111_777
        #expect(abs(parsed!.secondsSinceEpoch - expectedTimestamp) < 1)
    }

    @Test
    func `Parse invalid date`() async throws {
        #expect(RFC_5322.DateTime(try HTTP.Header.Field(name: "Date", value: "invalid")) == nil)
        #expect(RFC_5322.DateTime(try HTTP.Header.Field(name: "Date", value: "")) == nil)
        #expect(
            RFC_5322.DateTime(try HTTP.Header.Field(name: "Date", value: "2024-11-16")) == nil
        )  // Wrong format
    }

    @Test
    func `Equality`() async throws {
        let date1 = HTTP.Date(secondsSinceEpoch: 784_111_777)
        let date2 = HTTP.Date(secondsSinceEpoch: 784_111_777)
        let date3 = HTTP.Date(secondsSinceEpoch: 784_111_778)

        #expect(date1 == date2)
        #expect(date1 != date3)
    }

    @Test
    func `Hashable`() async throws {
        var set: Set<HTTP.Date> = []

        set.insert(HTTP.Date(secondsSinceEpoch: 784_111_777))
        set.insert(HTTP.Date(secondsSinceEpoch: 784_111_777))  // Duplicate
        set.insert(HTTP.Date(secondsSinceEpoch: 784_111_778))

        #expect(set.count == 2)
    }

    @Test
    func `Comparable`() async throws {
        let earlier = HTTP.Date(secondsSinceEpoch: 1000)
        let later = HTTP.Date(secondsSinceEpoch: 2000)

        #expect(earlier < later)
        #expect(later > earlier)
    }

    @Test
    func `Codable`() async throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        let httpDate = HTTP.Date(secondsSinceEpoch: 784_111_777)
        let encoded = try encoder.encode(httpDate)
        let decoded = try decoder.decode(HTTP.Date.self, from: encoded)

        let diff = abs(decoded.secondsSinceEpoch - httpDate.secondsSinceEpoch)
        #expect(diff < 1)  // Within 1 second
    }

    @Test
    func `Description`() async throws {
        let httpDate = HTTP.Date(secondsSinceEpoch: 784_111_777)

        let description = httpDate.description

        // Description is the RFC 5322 formatted string
        #expect(description.contains("Sun"))
        #expect(description.contains("06 Nov 1994"))
    }

    @Test
    func `Round trip - format and parse`() async throws {
        let original = HTTP.Date(secondsSinceEpoch: 784_111_777)

        let field = HTTP.Header.Field(dateTime: original)
        let parsed = RFC_5322.DateTime(field)

        #expect(parsed != nil)
        let diff = abs(parsed!.secondsSinceEpoch - original.secondsSinceEpoch)
        #expect(diff < 1)  // Within 1 second
    }
}

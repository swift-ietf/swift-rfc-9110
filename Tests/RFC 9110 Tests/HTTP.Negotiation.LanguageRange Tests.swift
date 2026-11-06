import RFC_9110
import Testing

@Suite
struct `HTTP.Negotiation.LanguageRange Tests` {

    @Test
    func `A basic range or the wildcard is accepted`() throws {
        #expect(try RFC_9110.Negotiation.LanguageRange("*") == .any)
        #expect(try RFC_9110.Negotiation.LanguageRange("en").value == "en")
        #expect(try RFC_9110.Negotiation.LanguageRange("en-GB").value == "en-GB")
        #expect(try RFC_9110.Negotiation.LanguageRange("de-1996").value == "de-1996")
        #expect(try RFC_9110.Negotiation.LanguageRange("abcdefgh-12345678").value == "abcdefgh-12345678")
    }

    @Test(arguments: ["", "en_US", "e1", "1996", "abcdefghi", "en-123456789", "-en", "en-", "en--GB", "*-CH"])
    func `Anything else is refused`(text: String) {
        #expect(throws: RFC_9110.Negotiation.LanguageRange.Error.self) {
            _ = try RFC_9110.Negotiation.LanguageRange(text)
        }
    }
}

import Testing

@testable import RFC_9110

@Suite
struct `Authentication challenge quoting` {
    @Test
    func `a value with a quote or backslash is quoted and escaped`() {
        let challenge = RFC_9110.Authentication.Challenge(scheme: .basic, realm: #"say "hi" \ x"#)
        #expect(challenge.headerValue == #"Basic realm="say \"hi\" \\ x""#)
    }

    @Test(arguments: ["a;b", "a@b", "(x)", "a/b"])
    func `a value that is not a token is quoted`(_ value: String) {
        let challenge = RFC_9110.Authentication.Challenge(scheme: .basic, realm: value)
        #expect(challenge.headerValue == "Basic realm=\"\(value)\"")
    }

    @Test
    func `an empty value is an empty quoted string`() {
        let challenge = RFC_9110.Authentication.Challenge(scheme: .basic, realm: "")
        #expect(challenge.headerValue == #"Basic realm="""#)
    }

    @Test
    func `a token value stays unquoted`() {
        let challenge = RFC_9110.Authentication.Challenge(scheme: .basic, realm: "api")
        #expect(challenge.headerValue == "Basic realm=api")
    }
}

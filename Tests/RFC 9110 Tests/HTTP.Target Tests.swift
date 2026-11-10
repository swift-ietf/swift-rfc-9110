import RFC_3986
import RFC_9110
import Testing

@Suite
struct `HTTP.Target Tests` {
    @Test(
        arguments: [
            ("/apps", ["apps"], nil),
            ("//apps", ["", "apps"], nil),
            ("/apps/", ["apps", ""], nil),
            ("/", [], nil),
            ("/apps?price=free", ["apps"], "price=free"),
            ("/apps?x", ["apps"], "x"),
            ("/apps?", ["apps"], ""),
        ] as [(String, [String], String?)]
    )
    func `a target that starts with a slash is origin-form, its path kept segment by segment`(
        text: String,
        segments: [String],
        query: String?
    ) throws {
        guard case .origin(let path, let found) = HTTP.Target(unchecked: text) else {
            Issue.record("\(text) is not origin-form")
            return
        }
        #expect(path.isAbsolute)
        #expect(path.segments == segments)
        #expect(found?.description == query)
    }

    @Test
    func `a target whose query is not a URI query is kept as written`() {
        #expect(
            HTTP.Target(unchecked: "/apps?q=%zz") == .resource(RFC_3986.URI(unchecked: "/apps?q=%zz"))
        )
    }

    @Test(arguments: [
        "/apps", "//apps", "/apps/", "/", "/apps?price=free", "/apps?x", "/apps?", "/apps?q=%zz",
        "https://example.com/a?b",
    ])
    func `an origin-form target or a URI reads back as it was written`(text: String) {
        #expect(HTTP.Target(unchecked: text).reference == text)
    }

    @Test
    func `an asterisk has no reference`() {
        #expect(HTTP.Target.asterisk.reference == nil)
    }

    @Test
    func `an absolute URI stays a resource`() throws {
        #expect(
            HTTP.Target(unchecked: "https://example.com//apps")
                == .resource(try RFC_3986.URI("https://example.com//apps"))
        )
    }

    @Test
    func `a target gives its path, whichever form holds it`() throws {
        #expect(HTTP.Target(unchecked: "//apps?x").path?.segments == ["", "apps"])
        #expect(HTTP.Target(unchecked: "https://example.com/a/b?c").path?.segments == ["a", "b"])
        #expect(HTTP.Target(unchecked: "/apps?q=%zz").path?.segments == ["apps"])
        #expect(HTTP.Target.asterisk.path == nil)
    }
}

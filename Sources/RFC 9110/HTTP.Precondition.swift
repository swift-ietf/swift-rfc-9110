import ASCII_Primitives
import Byte_Parser_Primitives
import Parser_Primitives
public import RFC_5322
import Standard_Library_Extensions

extension RFC_9110 {

    public enum Precondition: Sendable, Equatable {

        case ifMatch([RFC_9110.Entity.Tag])

        case ifNoneMatch([RFC_9110.Entity.Tag])

        case ifModifiedSince(RFC_5322.DateTime)

        case ifUnmodifiedSince(RFC_5322.DateTime)

        case ifRange(Validator)
    }
}

extension RFC_9110.Precondition {

    public static let wildcardTag = RFC_9110.Entity.Tag.strong("*")
}

extension RFC_9110.Precondition {

    public var headerName: String {
        switch self {
        case .ifMatch:
            return "If-Match"

        case .ifNoneMatch:
            return "If-None-Match"

        case .ifModifiedSince:
            return "If-Modified-Since"

        case .ifUnmodifiedSince:
            return "If-Unmodified-Since"

        case .ifRange:
            return "If-Range"
        }
    }

    public var headerValue: String {
        switch self {
        case .ifMatch(let etags):
            if etags.count == 1 && etags[0].value == "*" {
                return "*"
            }
            return etags.map { $0.headerValue }.joined(separator: ", ")

        case .ifNoneMatch(let etags):
            if etags.count == 1 && etags[0].value == "*" {
                return "*"
            }
            return etags.map { $0.headerValue }.joined(separator: ", ")

        case .ifModifiedSince(let date):
            return String(date)

        case .ifUnmodifiedSince(let date):
            return String(date)

        case .ifRange(.etag(let etag)):
            return etag.headerValue

        case .ifRange(.date(let date)):
            return String(date)
        }
    }
}

extension RFC_9110.Precondition {

    public static func parseIfMatch(_ headerValue: String) -> RFC_9110.Precondition? {
        var input = Byte.Input(utf8: headerValue)
        RFC_9110.Parse.OWS<Byte.Input>().parse(&input)

        if input.startIndex < input.endIndex, input[input.startIndex] == 0x2A {
            let saved = input
            input = input[input.index(after: input.startIndex)...]
            RFC_9110.Parse.OWS<Byte.Input>().parse(&input)
            if input.startIndex >= input.endIndex {
                return .ifMatch([wildcardTag])
            }
            input = saved
        }

        let etags = RFC_9110.Parse.CommaSeparated<Byte.Input, RFC_9110.Entity.Tag> { element in
            RFC_9110.Entity.Tag.parse(String(decoding: element, as: UTF8.self))
        }.parse(&input)

        return etags.isEmpty ? nil : .ifMatch(etags)
    }

    public static func parseIfNoneMatch(_ headerValue: String) -> RFC_9110.Precondition? {
        var input = Byte.Input(utf8: headerValue)
        RFC_9110.Parse.OWS<Byte.Input>().parse(&input)

        if input.startIndex < input.endIndex, input[input.startIndex] == 0x2A {
            let saved = input
            input = input[input.index(after: input.startIndex)...]
            RFC_9110.Parse.OWS<Byte.Input>().parse(&input)
            if input.startIndex >= input.endIndex {
                return .ifNoneMatch([wildcardTag])
            }
            input = saved
        }

        let etags = RFC_9110.Parse.CommaSeparated<Byte.Input, RFC_9110.Entity.Tag> { element in
            RFC_9110.Entity.Tag.parse(String(decoding: element, as: UTF8.self))
        }.parse(&input)

        return etags.isEmpty ? nil : .ifNoneMatch(etags)
    }

    public static func parseIfModifiedSince(_ headerValue: String) -> RFC_9110.Precondition? {
        let httpDate: RFC_5322.DateTime
        do throws(RFC_5322.DateTime.Error) {
            httpDate = try RFC_5322.DateTime(headerValue)
        } catch {
            return nil
        }
        return .ifModifiedSince(httpDate)
    }

    public static func parseIfUnmodifiedSince(_ headerValue: String) -> RFC_9110.Precondition? {
        let httpDate: RFC_5322.DateTime
        do throws(RFC_5322.DateTime.Error) {
            httpDate = try RFC_5322.DateTime(headerValue)
        } catch {
            return nil
        }
        return .ifUnmodifiedSince(httpDate)
    }

    public static func parseIfRange(_ headerValue: String) -> RFC_9110.Precondition? {
        let trimmed = String(headerValue.trimming(where: { $0.isWhitespace }))

        if let etag = RFC_9110.Entity.Tag.parse(trimmed) {
            return .ifRange(.etag(etag))
        }

        do throws(RFC_5322.DateTime.Error) {
            let httpDate = try RFC_5322.DateTime(trimmed)
            return .ifRange(.date(httpDate))
        } catch {

        }

        return nil
    }
}

extension RFC_9110.Precondition {

    public func evaluate(
        currentETag: RFC_9110.Entity.Tag?,
        lastModified: RFC_5322.DateTime?
    ) -> Bool {
        switch self {
        case .ifMatch(let etags):
            guard let currentETag else {
                return false
            }

            if etags.contains(where: { $0.value == "*" }) {
                return true
            }

            return etags.contains(where: { RFC_9110.Entity.Tag.strongCompare($0, currentETag) })

        case .ifNoneMatch(let etags):
            guard let currentETag else {

                return true
            }

            if etags.contains(where: { $0.value == "*" }) {
                return false
            }

            return !etags.contains(where: { RFC_9110.Entity.Tag.weakCompare($0, currentETag) })

        case .ifModifiedSince(let date):
            guard let lastModified else {

                return true
            }

            return lastModified > date

        case .ifUnmodifiedSince(let date):
            guard let lastModified else {

                return true
            }

            return lastModified <= date

        case .ifRange(.etag(let etag)):
            guard let currentETag else {
                return false
            }

            return RFC_9110.Entity.Tag.strongCompare(etag, currentETag)

        case .ifRange(.date(let date)):
            guard let lastModified else {
                return false
            }

            return lastModified <= date
        }
    }
}

extension RFC_9110.Precondition: CustomStringConvertible {
    public var description: String {
        return "\(headerName): \(headerValue)"
    }
}

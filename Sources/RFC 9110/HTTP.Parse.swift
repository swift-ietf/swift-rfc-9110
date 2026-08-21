import Byte_Parser_Primitives
import Byte_Primitives_Standard_Library_Integration
import Parser_Primitives

extension RFC_9110 {

    public enum Parse {}
}

extension RFC_9110.Parse {

    public enum Error {}
}

extension RFC_9110.Parse {

    public static func tokens(in headerValue: String) -> [String] {
        var input = Byte.Input(utf8: headerValue)
        return CommaSeparated<Byte.Input, String> { element in
            var sub = element
            let token: Byte.Input
            do throws(Token<Byte.Input>.Error) {
                token = try Token<Byte.Input>().parse(&sub)
            } catch {
                return nil
            }
            return String(decoding: token, as: UTF8.self)
        }.parse(&input)
    }

    public static func directives(in headerValue: String) -> [(name: String, value: String?)] {
        var input = Byte.Input(utf8: headerValue)
        return CommaSeparated<Byte.Input, (name: String, value: String?)> { element in
            var sub = element
            let nameSlice: Byte.Input
            do throws(Token<Byte.Input>.Error) {
                nameSlice = try Token<Byte.Input>().parse(&sub)
            } catch {
                return nil
            }
            let name = String(decoding: nameSlice, as: UTF8.self)

            OWS<Byte.Input>().parse(&sub)
            guard sub.startIndex < sub.endIndex, sub[sub.startIndex] == 0x3D else {
                return (name: name, value: nil)
            }
            sub = sub[sub.index(after: sub.startIndex)...]
            OWS<Byte.Input>().parse(&sub)

            do throws(QuotedString<Byte.Input>.Error) {
                let quoted = try QuotedString<Byte.Input>().parse(&sub)
                return (name: name, value: String(decoding: quoted, as: UTF8.self))
            } catch {

            }
            do throws(Token<Byte.Input>.Error) {
                let tokenSlice = try Token<Byte.Input>().parse(&sub)
                return (name: name, value: String(decoding: tokenSlice, as: UTF8.self))
            } catch {

            }

            return (name: name, value: nil)
        }.parse(&input)
    }
}

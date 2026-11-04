# swift-rfc-9110

Use this package when you work with HTTP meaning that does not depend on the protocol version: methods, status codes, header fields, media types, content negotiation, entity tags and conditional requests. Start from `RFC_9110.Message.Request` and `RFC_9110.Message.Response`, or from `RFC_9110.Negotiation` when you choose a representation from an Accept header. To reach the same types as `HTTP.*`, use swift-http. For HTTP/1.1 message framing use swift-rfc-9112, and for caching rules use swift-rfc-9111.

## Laws

- `RFC_9110.Field.Name` and `RFC_9110.Authentication.Scheme` compare and hash without regard to case, and keep the spelling they were given.
- `RFC_9110.Field.Value.init(_:)` refuses only CR and LF. A field name must be a non-empty token.
- `RFC_9110.Message.Headers` keeps every field line in the order given, duplicates included. Looking up a name returns all its values in that order.
- `RFC_9110.MediaType` lowercases its type and subtype. Equality and hashing ignore parameters, so `text/html` equals `text/html; charset=utf-8`. Parameters are written sorted by name.
- `RFC_9110.MediaType.matches(_:)` treats its argument as the pattern. `application/json` matches `application/*` and `*/*`, not the other way round.
- `RFC_9110.Representation.Encoding`, `RFC_9110.Negotiation.CharsetPreference` and the field names in `RFC_9110.Negotiation.Vary` are lowercased.
- `RFC_9110.Negotiation.Vary.matches(requestHeaders:cachedRequestHeaders:)` looks headers up by lowercased name, so both dictionaries need lowercased keys. `RFC_9110.Negotiation.Vary.all` includes every field and never matches.
- A quality value is a whole number of thousandths from 0 to 1000. Parsing accepts at most three decimals, and `1` may only be followed by zeros, so `0.1234` and `1.001` are refused. It prints without trailing zeros, as `1`, `0.9` or `0`.
- Parsed Accept preferences are sorted by quality, highest first. Among media types of equal quality, `type/subtype` comes before `type/*`, which comes before `*/*`. Among languages of equal quality, the longer tag comes first.
- One malformed element makes a whole field value list fail, so a header with one bad weight parses to no preferences at all. Empty list elements and whitespace around commas are allowed. Lists are written with a comma and a space.
- `RFC_9110.Negotiation.selectMediaTypes(from:acceptHeader:)` leaves out anything whose best matching quality is 0.
- `RFC_9110.Representation.Validator.EntityTag.strongCompare(_:_:)` is true only when both tags are strong and equal. `RFC_9110.Representation.Validator.EntityTag.weakCompare(_:_:)` ignores weakness. Plain equality counts weakness, so `W/"a"` and `"a"` are not equal.
- HTTP dates are written as IMF-fixdate in GMT, such as `Sun, 06 Nov 1994 08:49:37 GMT`. Parsing also accepts the obsolete RFC 850 and asctime forms. An RFC 850 two-digit year below 70 is read as 20xx, and any other as 19xx.
- `RFC_9110.Authentication.Challenge.headerValue` writes parameters sorted by name. A value that is a token is written bare. Any other value, including an empty one, is quoted with `"` and `\` escaped.
- `RFC_9110.Authentication.Credentials.basic(username:password:)` encodes `username:password` as UTF-8, then Base64. When credentials are parsed, the token is everything after the scheme and its whitespace, with trailing whitespace removed.
- `RFC_9110.Parameter.coder` writes a value as a token when it is one and quoted otherwise, and unescapes quoted values when parsing. `RFC_9110.MediaType.value` writes parameter values as they are, without quoting.
- `RFC_9110.MediaType` and `RFC_9110.Representation.Validator.EntityTag` encode as their header text and decode by parsing it. Text that does not parse fails to decode with a data-corrupted `DecodingError`.

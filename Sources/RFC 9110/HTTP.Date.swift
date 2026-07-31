// HTTP.Date.swift
// swift-rfc-9110
//
// RFC 9110 Section 5.6.7: Date/Time Formats
// https://www.rfc-editor.org/rfc/rfc9110.html#section-5.6.7
//
// HTTP dates are NOT RFC 5322 dates. RFC 5322 (email) ends a timestamp with a
// numeric zone (`+0000`); HTTP mandates the literal three-character zone `GMT`.
// `RFC_5322.DateTime` is reused as the underlying calendar VALUE, but HTTP owns
// the wire FORMAT (generation + parsing) declared here.

public import RFC_5322

extension RFC_9110 {
    /// HTTP Date/Time (RFC 9110 Section 5.6.7)
    ///
    /// HTTP uses its own date formats for timestamps in headers like
    /// `Date`, `Last-Modified`, and `Expires`. The calendar value is modeled by
    /// `RFC_5322.DateTime`; the HTTP wire format is applied at the header-field
    /// boundary (`HTTP.Header.Field(dateTime:)`).
    ///
    /// ## Format
    ///
    /// HTTP timestamps are generated in the preferred IMF-fixdate form, which is
    /// always expressed in GMT:
    /// ```
    /// Sun, 06 Nov 1994 08:49:37 GMT
    /// ```
    ///
    /// ## Example Usage
    ///
    /// ```swift
    /// // Create from an instant
    /// let httpDate = HTTP.Date(secondsSinceEpoch: 784_111_777)
    ///
    /// // Create a header field from the date
    /// let field = HTTP.Header.Field(dateTime: httpDate)
    /// // Field(name: "Date", value: "Sun, 06 Nov 1994 08:49:37 GMT")
    ///
    /// // Parse from a header field (any of the three HTTP-date formats)
    /// if let parsed = RFC_5322.DateTime(field) {
    ///     print(parsed)
    /// }
    /// ```
    ///
    /// ## RFC 9110 Reference
    ///
    /// From RFC 9110 Section 5.6.7:
    /// ```
    /// HTTP-date    = IMF-fixdate / obs-date
    /// IMF-fixdate  = day-name "," SP date1 SP time-of-day SP GMT
    /// obs-date     = rfc850-date / asctime-date
    /// ```
    ///
    /// ## Reference
    ///
    /// - [RFC 9110 Section 5.6.7: Date/Time Formats](https://www.rfc-editor.org/rfc/rfc9110.html#section-5.6.7)
    /// - [RFC 5322: Internet Message Format](https://www.rfc-editor.org/rfc/rfc5322.html)
    ///
    /// ## Note
    ///
    /// Generation emits IMF-fixdate only (the format RFC 9110 mandates for new
    /// messages). Parsing accepts all three formats a recipient MUST handle:
    /// IMF-fixdate, the obsolete RFC 850 form, and the asctime form.
    public typealias Date = RFC_5322.DateTime
}

// MARK: - HTTP.Header.Field -> RFC_5322.DateTime (parsing)

extension RFC_5322.DateTime {
    /// Creates a date-time from an HTTP header field value.
    ///
    /// Parses date headers like `Date`, `Last-Modified`, and `Expires`. Per
    /// RFC 9110 Section 5.6.7 a recipient MUST accept all three HTTP-date
    /// formats: IMF-fixdate, the obsolete RFC 850 form, and the asctime form.
    /// All three are GMT.
    ///
    /// - Parameter field: The HTTP header field containing the date
    ///
    /// ## Example
    ///
    /// ```swift
    /// let field = try HTTP.Header.Field(name: "Date", value: "Sun, 06 Nov 1994 08:49:37 GMT")
    /// if let dateTime = RFC_5322.DateTime(field) {
    ///     print(dateTime)
    /// }
    /// ```
    public init?(_ field: RFC_9110.Header.Field) {
        self.init(field.value)
    }

    /// Creates a date-time from an HTTP header field value.
    ///
    /// Accepts the three HTTP-date formats of RFC 9110 Section 5.6.7
    /// (IMF-fixdate, obsolete RFC 850, asctime).
    ///
    /// - Parameter value: The HTTP header field value containing the date
    public init?(_ value: RFC_9110.Header.Field.Value) {
        guard let parsed = parseHTTPDate(value.rawValue) else {
            return nil
        }
        self = parsed
    }
}

// MARK: - RFC_5322.DateTime -> HTTP.Header.Field (generation)

extension RFC_9110.Header.Field {
    /// Creates a date header field from a date-time, formatted as IMF-fixdate.
    ///
    /// Format: `<day-name>, <DD> <month-name> <YYYY> <HH>:<MM>:<SS> GMT`
    /// (RFC 9110 Section 5.6.7). The instant is always rendered in GMT,
    /// regardless of the date-time's stored timezone offset.
    ///
    /// - Parameter dateTime: The date-time to format
    /// - Parameter name: The header name (default: `.date`)
    ///
    /// ## Example
    ///
    /// ```swift
    /// let dateTime = HTTP.Date(secondsSinceEpoch: 784_111_777)
    /// let field = HTTP.Header.Field(dateTime: dateTime)
    /// // Field(name: "Date", value: "Sun, 06 Nov 1994 08:49:37 GMT")
    /// ```
    public init(dateTime: RFC_5322.DateTime, name: Name = .date) {
        self.init(
            name: name,
            value: .init(unchecked: imfFixdate(dateTime))
        )
    }
}

// MARK: - IMF-fixdate Generation

/// Renders a date-time as an RFC 9110 IMF-fixdate string (always GMT).
///
/// `<day-name>, <DD> <month-name> <YYYY> <HH>:<MM>:<SS> GMT`
private func imfFixdate(_ dateTime: RFC_5322.DateTime) -> String {
    // Normalize to GMT: HTTP dates are always expressed in GMT regardless of the
    // value's stored timezone offset.
    let components = dateTime.withTimezone(offsetSeconds: 0).components

    let dayName = RFC_5322.DateTime.dayNames[components.weekday]
    let monthName = RFC_5322.DateTime.monthNames[components.month - 1]

    let day = paddedDecimal(components.day, width: 2)
    let year = paddedDecimal(components.year, width: 4)
    let hour = paddedDecimal(components.hour, width: 2)
    let minute = paddedDecimal(components.minute, width: 2)
    let second = paddedDecimal(components.second, width: 2)

    return "\(dayName), \(day) \(monthName) \(year) \(hour):\(minute):\(second) GMT"
}

/// Zero-pads a non-negative integer to a fixed number of ASCII decimal digits.
private func paddedDecimal(_ value: Int, width: Int) -> String {
    let digits = String(value)
    guard digits.count < width else { return digits }
    return String(repeating: "0", count: width - digits.count) + digits
}

// MARK: - HTTP-date Parsing (RFC 9110 Section 5.6.7)

/// Parses any of the three HTTP-date formats into a GMT date-time.
///
/// - IMF-fixdate: `Sun, 06 Nov 1994 08:49:37 GMT`
/// - RFC 850 (obsolete): `Sunday, 06-Nov-94 08:49:37 GMT`
/// - asctime (obsolete): `Sun Nov  6 08:49:37 1994`
///
/// The day-name is not validated against the calendar — the numeric date is
/// authoritative. The numeric zone form (`+0000`) is intentionally rejected:
/// it is an RFC 5322 (email) construct, not an HTTP-date.
private func parseHTTPDate(_ string: String) -> RFC_5322.DateTime? {
    if let comma = string.firstIndex(of: ",") {
        // IMF-fixdate or RFC 850 — both carry a `day-name ","` prefix.
        let fields = string[string.index(after: comma)...]
            .split(whereSeparator: isHTTPDateSpace)
            .map(String.init)
        // RFC 850's date is hyphen-joined (`06-Nov-94`); IMF's is space-separated.
        if let first = fields.first, first.contains("-") {
            return parseRFC850Date(fields)
        }
        return parseIMFFixdate(fields)
    }
    // asctime has no comma.
    let fields = string.split(whereSeparator: isHTTPDateSpace).map(String.init)
    return parseAsctimeDate(fields)
}

/// IMF-fixdate body: `["06", "Nov", "1994", "08:49:37", "GMT"]`.
private func parseIMFFixdate(_ fields: [String]) -> RFC_5322.DateTime? {
    guard fields.count == 5, fields[4] == "GMT" else { return nil }
    guard
        let day = Int(fields[0]),
        let month = monthNumber(fields[1]),
        let year = Int(fields[2]), fields[2].count == 4,
        let time = parseTimeOfDay(fields[3])
    else { return nil }
    return gmtDateTime(year: year, month: month, day: day, time: time)
}

/// RFC 850 body: `["06-Nov-94", "08:49:37", "GMT"]`.
private func parseRFC850Date(_ fields: [String]) -> RFC_5322.DateTime? {
    guard fields.count == 3, fields[2] == "GMT" else { return nil }
    let date = fields[0].split(separator: "-", omittingEmptySubsequences: false).map(String.init)
    guard
        date.count == 3,
        let day = Int(date[0]),
        let month = monthNumber(date[1]),
        date[2].count == 2, let twoDigitYear = Int(date[2]),
        let time = parseTimeOfDay(fields[1])
    else { return nil }
    // RFC 9110 §5.6.7: a two-digit year is interpreted via a fixed pivot — years
    // < 70 are 2000-based, otherwise 1900-based (clock-free, deterministic).
    let year = twoDigitYear < 70 ? 2000 + twoDigitYear : 1900 + twoDigitYear
    return gmtDateTime(year: year, month: month, day: day, time: time)
}

/// asctime body: `["Sun", "Nov", "6", "08:49:37", "1994"]` (no zone — GMT implied).
private func parseAsctimeDate(_ fields: [String]) -> RFC_5322.DateTime? {
    guard fields.count == 5 else { return nil }
    guard
        let month = monthNumber(fields[1]),
        let day = Int(fields[2]),
        let time = parseTimeOfDay(fields[3]),
        let year = Int(fields[4]), fields[4].count == 4
    else { return nil }
    return gmtDateTime(year: year, month: month, day: day, time: time)
}

/// Parses `HH:MM:SS` (or `HH:MM`) into numeric components.
private func parseTimeOfDay(_ field: String) -> (hour: Int, minute: Int, second: Int)? {
    let parts = field.split(separator: ":", omittingEmptySubsequences: false)
    guard parts.count == 2 || parts.count == 3 else { return nil }
    guard let hour = Int(parts[0]), let minute = Int(parts[1]) else { return nil }
    if parts.count == 3 {
        guard let second = Int(parts[2]) else { return nil }
        return (hour, minute, second)
    }
    return (hour, minute, 0)
}

/// Maps a three-letter month abbreviation to its 1-based month number.
private func monthNumber(_ name: String) -> Int? {
    RFC_5322.DateTime.monthNames.firstIndex(of: name).map { $0 + 1 }
}

/// Builds a GMT date-time from validated components, or `nil` on a calendar error.
private func gmtDateTime(
    year: Int,
    month: Int,
    day: Int,
    time: (hour: Int, minute: Int, second: Int)
) -> RFC_5322.DateTime? {
    // RFC_5322.DateTime.init(year:...) throws the L1 `Time.Error` type from
    // swift-time-primitives, a package this target does not otherwise
    // depend on; naming that type in a `do throws(Time.Error)` here would
    // require adding a new direct dependency solely to spell a caught error
    // type. Deferred pending a dependency-addition decision — see
    // adjudication request on the tracking issue.
    // swift-linter:disable:next try optional
    // REASON: see explanation above.
    // swiftlint:disable:next no_try_optional - reason: see explanation above
    try? RFC_5322.DateTime(
        year: year,
        month: month,
        day: day,
        hour: time.hour,
        minute: time.minute,
        second: time.second,
        timezoneOffsetSeconds: 0
    )
}

/// HTTP-date field separators: SP and HTAB.
private func isHTTPDateSpace(_ character: Character) -> Bool {
    character == " " || character == "\t"
}

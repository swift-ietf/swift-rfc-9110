// HTTP.Content.Negotiation.QualityValue.swift
// swift-rfc-9110

import Byte_Parser_Primitives

extension RFC_9110.Content.Negotiation {
    /// A quality value represented exactly as RFC 9110 thousandths.
    public struct QualityValue: Sendable, Equatable, Hashable, Comparable {
        /// The canonical value in the closed range `0...1000`.
        public let thousandths: Int

        /// Creates a quality value when `thousandths` is in `0...1000`.
        public init?(_ thousandths: Int) {
            guard (0...1000).contains(thousandths) else { return nil }
            self.thousandths = thousandths
        }

        private init(unchecked thousandths: Int) {
            self.thousandths = thousandths
        }
    }
}

extension RFC_9110.Content.Negotiation.QualityValue {
    /// Parses one complete RFC 9110 `qvalue`.
    public static func parse(_ string: String) -> Self? {
        var input = Byte.Input(utf8: string)
        let thousandths: Int
        do throws(RFC_9110.Parse.Error.QualityValue) {
            thousandths = try RFC_9110.Parse.QualityValue<Byte.Input>().parse(&input)
        } catch {
            return nil
        }
        guard input.isEmpty else { return nil }
        return Self(thousandths)
    }

    public static let `default` = Self(unchecked: 1000)
    public static let zero = Self(unchecked: 0)

    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.thousandths < rhs.thousandths
    }
}

extension RFC_9110.Content.Negotiation.QualityValue: CustomStringConvertible {
    public var description: String {
        guard thousandths != 1000 else { return "1" }
        guard thousandths != 0 else { return "0" }

        let digits = String(thousandths + 1000).dropFirst()
        return "0.\(digits)".replacing(/0+$/, with: "")
    }
}

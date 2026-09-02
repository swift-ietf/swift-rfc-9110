import Byte
import Byte_Parser

extension RFC_9110.Message.Content.Negotiation {

    public struct QualityValue: Sendable, Equatable, Hashable, Comparable {

        public let thousandths: Int

        public init?(_ thousandths: Int) {
            guard (0...1000).contains(thousandths) else { return nil }
            self.thousandths = thousandths
        }

        private init(unchecked thousandths: Int) {
            self.thousandths = thousandths
        }
    }
}

extension RFC_9110.Message.Content.Negotiation.QualityValue {

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

extension RFC_9110.Message.Content.Negotiation.QualityValue: CustomStringConvertible {
    public var description: String {
        guard thousandths != 1000 else { return "1" }
        guard thousandths != 0 else { return "0" }

        let digits = String(thousandths + 1000).dropFirst()
        return "0.\(digits)".replacing(/0+$/, with: "")
    }
}

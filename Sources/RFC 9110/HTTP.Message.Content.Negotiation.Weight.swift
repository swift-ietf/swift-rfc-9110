public import Byte
public import Checkpoint
public import Cursor
public import Iterator
public import Iterator_Protocol
import Parser

extension RFC_9110.Message.Content.Negotiation {

    package enum Weight: Sendable, Equatable {
        case absent
        case value(QualityValue)
        case invalid
    }
}

extension RFC_9110.Message.Content.Negotiation.Weight {

    static func parse<Input: Cursor.`Protocol`>(_ input: inout Input) -> Self
    where Input.Element == Byte, Input.Failure == Never {
        let start = input.checkpoint
        RFC_9110.Parse.OWS<Input>().parse(&input)

        guard let semicolon = input.next(), semicolon.bitPattern == 0x3B else {
            input.seek(to: start)
            return .absent
        }
        RFC_9110.Parse.OWS<Input>().parse(&input)

        guard let q = input.next(), q.bitPattern == 0x71 || q.bitPattern == 0x51 else {
            return .invalid
        }
        guard let equals = input.next(), equals.bitPattern == 0x3D else { return .invalid }

        let thousandths: Int
        do throws(RFC_9110.Parse.Error.QualityValue) {
            thousandths = try RFC_9110.Parse.QualityValue<Input>().parse(&input)
        } catch {
            return .invalid
        }
        RFC_9110.Parse.OWS<Input>().parse(&input)
        guard let quality = RFC_9110.Message.Content.Negotiation.QualityValue(thousandths)
        else { return .invalid }
        return .value(quality)
    }

    package static func parse(parameter: String?) -> Self {
        guard let parameter else { return .absent }
        guard let quality = RFC_9110.Message.Content.Negotiation.QualityValue.parse(parameter) else {
            return .invalid
        }
        return .value(quality)
    }
}

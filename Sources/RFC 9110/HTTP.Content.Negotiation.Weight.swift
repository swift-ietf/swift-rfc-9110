// HTTP.Content.Negotiation.Weight.swift
// swift-rfc-9110

import Byte_Primitive
import Byte_Parser_Primitives

extension RFC_9110.Content.Negotiation {
    /// The three possible outcomes when adapting an optional preference weight.
    package enum Weight: Sendable, Equatable {
        case absent
        case value(QualityValue)
        case invalid
    }
}

extension RFC_9110.Content.Negotiation.Weight {
    static func parse(_ input: inout Byte.Input) -> Self {
        RFC_9110.Parse.OWS<Byte.Input>().parse(&input)
        guard !input.isEmpty else { return .absent }
        guard input[input.startIndex] == 0x3B else { return .invalid }
        input = input[input.index(after: input.startIndex)...]
        RFC_9110.Parse.OWS<Byte.Input>().parse(&input)

        guard !input.isEmpty else { return .invalid }
        let q = input[input.startIndex]
        guard q == 0x71 || q == 0x51 else { return .invalid }
        input = input[input.index(after: input.startIndex)...]
        guard !input.isEmpty, input[input.startIndex] == 0x3D else { return .invalid }
        input = input[input.index(after: input.startIndex)...]

        let thousandths: Int
        do throws(RFC_9110.Parse.Error.QualityValue) {
            thousandths = try RFC_9110.Parse.QualityValue<Byte.Input>().parse(&input)
        } catch {
            return .invalid
        }
        RFC_9110.Parse.OWS<Byte.Input>().parse(&input)
        guard input.isEmpty,
            let quality = RFC_9110.Content.Negotiation.QualityValue(thousandths)
        else { return .invalid }
        return .value(quality)
    }

    package static func parse(parameter: String?) -> Self {
        guard let parameter else { return .absent }
        guard let quality = RFC_9110.Content.Negotiation.QualityValue.parse(parameter) else {
            return .invalid
        }
        return .value(quality)
    }
}

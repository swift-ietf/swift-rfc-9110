// HTTP.Header.Field.Name.Error.swift
// swift-rfc-9110

extension RFC_9110.Header.Field.Name {
    public enum Error: Swift.Error, Sendable, Equatable {
        case empty
        case invalidCharacter(UInt8)
    }
}

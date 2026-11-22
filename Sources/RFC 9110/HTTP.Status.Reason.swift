public import Byte

extension IETF.RFC.`9110`.Status {
    public struct Reason: Sendable, Equatable, Hashable {
        public var bytes: [Byte]

        public init(_ bytes: [Byte]) {
            self.bytes = bytes
        }
    }
}

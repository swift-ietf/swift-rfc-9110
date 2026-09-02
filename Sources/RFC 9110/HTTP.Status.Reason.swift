public import Byte

extension RFC_9110.Status {
    public struct Reason: Equatable, Hashable {
        public var bytes: [Byte]

        public init(_ bytes: [Byte]) {
            self.bytes = bytes
        }
    }
}

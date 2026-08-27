extension RFC_9110.Version {
    public enum Error: Swift.Error, Equatable {
        case invalid(UInt)
    }
}

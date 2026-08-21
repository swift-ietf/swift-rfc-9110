extension RFC_9110.Request.Target {

    public struct Form: Sendable {
        let target: RFC_9110.Request.Target
    }

    public var form: Form { Form(target: self) }
}

extension RFC_9110.Request.Target.Form {

    public var isOrigin: Bool {
        if case .origin = target { return true }
        return false
    }

    public var isAbsolute: Bool {
        if case .absolute = target { return true }
        return false
    }

    public var isAuthority: Bool {
        if case .authority = target { return true }
        return false
    }

    public var isAsterisk: Bool {
        if case .asterisk = target { return true }
        return false
    }
}

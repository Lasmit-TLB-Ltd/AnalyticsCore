public struct ErrorEvent: AnalyticsEvent {

    public var message: String
    public var context: String?
    public var additionalProperties: [String: Any]?

    public var name: String {
        "[Error] \(message)"
    }

    public var properties: [String: Any]? {
        var props: [String: Any] = [:]

        if let context = context {
            props["context"] = context
        }

        if let additionalProperties = additionalProperties {
            props.merge(additionalProperties) { _, new in new }
        }

        return props.isEmpty ? nil : props
    }

    public init(message: String, context: String? = nil, properties: [String: Any]? = nil) {
        self.message = message
        self.context = context
        self.additionalProperties = properties
    }
}

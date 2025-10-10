public struct ScreenViewEvent: AnalyticsEvent {
    public var properties: [String: Any]? = nil
    public var name: String

    public init(name: String) {
        self.name = "[Screen] " + name
    }
}

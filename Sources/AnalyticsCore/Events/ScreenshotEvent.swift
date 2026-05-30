public struct ScreenshotEvent: AnalyticsEvent {
    public var name: String { "[Screenshot]" }
    public var properties: [String: Any]? { nil }

    public init() {}
}

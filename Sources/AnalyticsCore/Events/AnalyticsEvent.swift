public protocol AnalyticsEvent {
    var name: String { get }
    var properties: [String: Any]? { get }
}

public protocol AnalyticsUserProperty {
    var name: String { get }
    var value: Any { get }
}

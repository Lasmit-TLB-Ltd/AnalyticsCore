
public class AnalyticsManager {
    
    nonisolated(unsafe) public static var eventHandler: ((AnalyticsEvent) -> Void)?

    nonisolated(unsafe) public static var propertyHandler: ((AnalyticsUserProperty) -> Void)?
    
    public static func logEvent(_ event: AnalyticsEvent) {
        eventHandler?(event)
    }
    
    public static func setUserProperty(_ property: AnalyticsUserProperty) {
        propertyHandler?(property)
    }
}

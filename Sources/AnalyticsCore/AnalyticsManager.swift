import AmplitudeSwift
import os
import CocoaLumberjackSwift


public class AnalyticsManager {
    
    nonisolated(unsafe) private static var amplitude: Amplitude?
    
    public static func setup(apiKey: String) {
        Self.amplitude = Amplitude(configuration: Configuration(
            apiKey: apiKey,
            autocapture: .screenViews
        ))
    }
    
    public static func logEvent(_ event: AnalyticsEvent) {
        guard let amplitude else {
            DDLogError("Amplitude not configured")
            return
        }
        
        var propertiesDescription = ""

        if let props = event.properties, props.count > 0 {
            propertiesDescription = props.description
        }
        DDLogDebug("[📍] \(event.name) \(propertiesDescription)")

        let props = event.properties ?? [String: Any]()

        amplitude.track(
            eventType: event.name,
            eventProperties: props
        )

#if !os(watchOS)
        if let purchaseEvent = event as? Purchase, purchaseEvent.source == nil {
            DDLogWarn("[📍⚠️] Unknown Purchase Event Source")
        }
#endif
        flush()
    }
    
    public static func setUserProperty(_ property: AnalyticsUserProperty) {
        guard let amplitude else {
            DDLogError("Amplitude not configured")
            return
        }
        
        let identify = Identify()
        identify.set(property: property.name, value: property.value)
        amplitude.identify(identify: identify)
    }
    
    private static func flush() {
#if DEBUG
        guard let amplitude else {
            DDLogError("Amplitude not configured")
            return
        }
        
        amplitude.flush()
#endif
    }
}

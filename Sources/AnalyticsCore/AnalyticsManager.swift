import AmplitudeSwift
import os
import CocoaLumberjackSwift

/// A simple, consistent way to track analytics use between apps.
/// Focussed on key events like onboarding and paywall interaction.
/// As well as screen views.
/// The goal is to avoid analytics bloat and focus on things which move the needle.
/// This keeps complexity and costs down.
public class AnalyticsManager {
    
    nonisolated(unsafe) private static var amplitude: Amplitude?
    
    public static func setup(apiKey: String) {
        Self.amplitude = Amplitude(configuration: Configuration(
            apiKey: apiKey,
            serverZone: .EU,
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
        if let paywallEvent = event as? Paywall, paywallEvent.source == nil {
            DDLogWarn("[📍⚠️] Unknown Paywall Event Source")
        }
#endif
        flush()
    }
    
    public static func identify(userId: String) {
        guard let amplitude else {
            DDLogError("Amplitude not configured")
            return
        }

        amplitude.setUserId(userId: userId)
        DDLogDebug("[📍] User identified: \(userId)")
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

    public static func startExperiment(name: String, variant: String) {
        // Track the experiment event
        logEvent(Experiment(name: name, variant: variant))

        // Set the experiment as a user property
        setUserProperty(ExperimentUserProperty(name: name, variant: variant))
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

import AmplitudeSwift
import os
import CocoaLumberjackSwift

#if canImport(UIKit)
import UIKit
#elseif canImport(WatchKit)
import WatchKit
#endif

/// A simple, consistent way to track analytics use between apps.
/// Focussed on key events like onboarding and paywall interaction.
/// As well as screen views.
/// The goal is to avoid analytics bloat and focus on things which move the needle.
/// This keeps complexity and costs down.
public class AnalyticsManager {
    
    nonisolated(unsafe) private static var amplitude: Amplitude?
    
    public static func setup(apiKey: String, uniqueId: String? = nil, runInDebugMode: Bool = false) {
        Self.amplitude = Amplitude(configuration: Configuration(
            apiKey: apiKey,
            logLevel: runInDebugMode ? .DEBUG : .WARN, // Warn is the default
            serverZone: .EU,
            autocapture: [],
        ))

        setOSVersionProperty()
        if let uniqueId {
            identify(userId: uniqueId)
        }
    }

    /// Parses the major version number from a version string
    /// - Parameter versionString: A version string like "17.5.1" or "9.0"
    /// - Returns: The major version number, or nil if parsing fails or version is 0
    static func parseMajorVersion(from versionString: String) -> Int? {
        let majorVersion = Int(versionString.split(separator: ".").first ?? "0") ?? 0
        return majorVersion > 0 ? majorVersion : nil
    }

    private static func setOSVersionProperty() {
#if os(iOS)
        let version = UIDevice.current.systemVersion
        if let majorVersion = parseMajorVersion(from: version) {
            setUserProperty(SystemUserProperty.osVersion(majorVersion))
        } else {
            DDLogError("Could not extract major version from \(version)")
        }
#elseif os(watchOS)
        let version = WKInterfaceDevice.current().systemVersion
        if let majorVersion = parseMajorVersion(from: version) {
            setUserProperty(SystemUserProperty.osVersion(majorVersion))
        } else {
            DDLogError("Could not extract major version from \(version)")
        }
#endif
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

        if event is ErrorEvent {
            DDLogError("📍 \(event.name) \(propertiesDescription)")
        } else {
            DDLogInfo("📍 \(event.name) \(propertiesDescription)")
        }

        let props = event.properties ?? [String: Any]()

        amplitude.track(
            eventType: event.name,
            eventProperties: props
        )

#if !os(watchOS)
        if let paywallEvent = event as? PaywallEvent, paywallEvent.source == nil {
            DDLogWarn("📍 Unknown Paywall Event Source")
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
        DDLogInfo("[📍] \(property.name) set to: \(property.value)")
    }

    public static func startExperiment(name: String, variant: String) {
        // Track the experiment event
        logEvent(ExperimentEvent(name: name, variant: variant))

        // Set the experiment as a user property
        setUserProperty(ExperimentUserProperty(name: name, variant: variant))
    }

    /// Creates an experiment and automatically tracks it
    ///
    /// This is the recommended way to start an experiment as it ensures the experiment
    /// instance and tracking are always in sync.
    ///
    /// ```swift
    /// enum MyExperiments: String {
    ///     case newFeature
    /// }
    ///
    /// let experiment = AnalyticsManager.createExperiment(name: MyExperiments.newFeature)
    /// if experiment.doNewThing {
    ///     // Use new feature
    /// }
    /// ```
    ///
    /// - Parameter name: The experiment name
    /// - Returns: The created experiment instance
    public static func createExperiment<Name: RawRepresentable>(name: Name) -> Experiment<Name> where Name.RawValue == String {
        let experiment = Experiment(name: name)
        startExperiment(name: experiment.name.rawValue, variant: experiment.variant.rawValue)
        return experiment
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

//
//  Experiment.swift
//  AnalyticsCore
//
//  Created by Lewis Smith on 10/10/2025.
//

import Foundation

/// Details of an A/B test experiment
///
/// `Experiment` provides a simple way to run A/B tests in your app by automatically assigning users
/// to cohorts (control or change) and persisting their assignment across sessions.
///
/// ## Usage Example
///
/// **Recommended**: Use `AnalyticsManager.createExperiment()` to create and track atomically:
///
/// ```swift
/// // 1. Define your experiment names
/// enum MyExperiments: String {
///     case newOnboardingFlow
///     case alternativePaywallDesign
/// }
///
/// // 2. Create and track the experiment in one call
/// let experiment = AnalyticsManager.createExperiment(name: MyExperiments.newOnboardingFlow)
///
/// // 3. Branch your code based on the variant
/// if experiment.doNewThing {
///     // Show new onboarding flow (change variant)
///     showNewOnboarding()
/// } else {
///     // Show existing onboarding (control variant)
///     showExistingOnboarding()
/// }
/// ```
///
/// **Alternative**: Manual creation and tracking:
///
/// ```swift
/// let experiment = Experiment(name: MyExperiments.newOnboardingFlow)
/// AnalyticsManager.startExperiment(
///     name: experiment.name.rawValue,
///     variant: experiment.variant.rawValue
/// )
/// if experiment.doNewThing { /* ... */ }
/// ```
///
/// ## Behavior
///
/// - **Production**: Users are randomly assigned to control or change variant on first run.
///   Their assignment is persisted in UserDefaults for consistency across sessions.
/// - **Debug**: Always assigns users to the `.change` variant for easier testing.
/// - **Manual Override**: You can specify a variant explicitly for testing purposes.
///
public struct Experiment<Name: RawRepresentable> where Name.RawValue == String {

    /// What cohort is the user in
    public enum Variant: String {
        /// The existing/previous value
        case control
        /// The new value under test
        case change

        private static var random: Variant {
            return [.control, .change].randomElement()!
        }

        /// Lookup previously assigned variant, if none found assign at random and remember for next time
        static func assigned(for name: Name) -> Variant {
            let defaultsKey = "Experiment_" + name.rawValue
            if let group = Variant(rawValue: UserDefaults.standard.string(forKey: defaultsKey) ?? "empty don't match") {
                return group
            }

            let newGroup = Variant.random
            UserDefaults.standard.set(newGroup.rawValue, forKey: defaultsKey)
            UserDefaults.standard.synchronize()
            return newGroup
        }
    }

    /// Name of the experiment
    public let name: Name

    /// Whether we belong to A or B
    public var variant: Variant


    /// Are we in the cohort that does the new thing in this experiment?
    public var doNewThing: Bool { return variant == .change }

    /// Creates an experiment with optional variant override
    ///
    /// **Note**: Consider using `AnalyticsManager.createExperiment()` instead, which creates
    /// and tracks the experiment atomically, preventing sync issues.
    ///
    /// - If `variant` is provided: Uses that variant and **persists it** for future sessions
    /// - If `variant` is nil: Randomly assigns and persists variant to UserDefaults
    ///
    /// - Note: When you provide an explicit variant, it's saved to UserDefaults. Future instances
    ///   of this experiment will use the saved variant until you clear UserDefaults or reinstall the app.
    ///
    /// - Parameters:
    ///   - name: The experiment name
    ///   - variant: Explicit variant for testing. If nil, assigns randomly and persists.
    public init(name: Name, variant: Variant? = nil) {
        self.name = name

        if let variant = variant {
            self.variant = variant
            // Persist the manually set variant so future instances use it
            let defaultsKey = "Experiment_" + name.rawValue
            UserDefaults.standard.set(variant.rawValue, forKey: defaultsKey)
            UserDefaults.standard.synchronize()
        } else {
            self.variant = .assigned(for: name)
        }
    }
}

extension Experiment: CustomStringConvertible {
    public var description: String {
        return "\(name.rawValue): \(variant.rawValue)"
    }
}

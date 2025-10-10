//
//  Experiment.swift
//  AnalyticsCore
//
//  Created by Lewis Smith on 10/10/2025.
//

import Foundation

/// Details of an A/B test experiment
struct Experiment<Name: RawRepresentable> where Name.RawValue == String {

    /// What cohort is the user in
    enum Variant: String {
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
            return newGroup
        }
    }

    /// Name of the experiment
    let name: Name

    // Whether we belong to A or B
    var variant: Variant

    init(name: Name) {
        self.name = name
        #if DEBUG
            variant = .change
        #else
            variant = Variant.assigned(for: name)
        #endif
    }

    /// Are we in the cohort that does the new thing in this experiment?
    var doNewThing: Bool { return variant == .change }
}

extension Experiment {
    /// Initialise an experiment
    /// - Parameters:
    ///   - name: the experiment to use
    ///   - variant: if nil a variant is assigned at random and persisted for future sessions. You probably only want to set a value during debugging/testing
    init(name: Name, variant: Variant? = nil) {
        self.name = name

        if let variant = variant {
            self.variant = variant
        } else {
            self.variant = .assigned(for: name)
        }
    }
}

extension Experiment: CustomStringConvertible {
    var description: String {
        return "\(name.rawValue): \(variant.rawValue)"
    }
}

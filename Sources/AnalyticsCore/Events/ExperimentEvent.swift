import Foundation

struct ExperimentEvent: AnalyticsEvent {
    let name: String
    let properties: [String: Any]?

    init(name: String, variant: String) {
        self.name = "[Experiment] \(name)"
        self.properties = [
            // use the experiment name as the property name so that it
            // matches the property name of other events
            name: variant
        ]
    }
}

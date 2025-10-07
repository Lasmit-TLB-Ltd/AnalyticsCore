import Foundation

struct ExperimentUserProperty: AnalyticsUserProperty {
    let name: String
    let value: Any

    init(name: String, variant: String) {
        self.name = "experiment_\(name)"
        self.value = variant
    }
}

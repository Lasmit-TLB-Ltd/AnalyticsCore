import Foundation

struct Experiment: AnalyticsEvent {
    let name: String
    let properties: [String: Any]?

    init(name: String, variant: String) {
        self.name = "[Experiment] \(name)"
        self.properties = ["variant": variant]
    }
}

public struct Other: AnalyticsEvent {

    var title: String
    var name: String { "\(title)" }

    var properties: [String : Any]?
}

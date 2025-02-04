public struct Other: AnalyticsEvent {

    public var title: String
    public var name: String { "\(title)" }

    public var properties: [String : Any]?
    
    public init(title: String, properties: [String : Any]? = nil) {
        self.title = title
        self.properties = properties
    }
}

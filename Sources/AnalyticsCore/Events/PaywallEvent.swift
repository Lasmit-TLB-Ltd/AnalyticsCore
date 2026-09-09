public struct PaywallEvent: AnalyticsEvent {

    public enum PurchaseEventType {
        case showSalesScreen
        case purchaseStarted
        case purchaseCompleted
        case dismissUpgrade
        case restore
    }

    public var type: PurchaseEventType
    public var source: String?
    public var period: String?

    /// The RevenueCat offering the paywall was shown from, when the app runs more than one.
    /// Lets a promotional paywall's funnel be separated from the standard one in Mixpanel.
    public var offering: String?

    public var name: String {
        let prefix = "[Paywall] "
        var suffix: String
        switch type {
            case .showSalesScreen:   suffix = "Shown"
            case .dismissUpgrade:    suffix = "Dismissed"
            case .restore:           suffix = "Purchase Restored"
            case .purchaseStarted:   suffix = "Purchase Started"
            case .purchaseCompleted: suffix = "Purchase Completed"
        }

        return prefix + suffix
    }

    public var properties: [String : Any]? {
        var props = ["source": source ?? "--" ]

        if type == .purchaseCompleted {
            if let period = period {
                props["period"] = period.description
            }
        }

        if let offering {
            props["offering"] = offering
        }

        return props
    }

    public init(type: PurchaseEventType, source: String? = nil, period: String? = nil, offering: String? = nil) {
        self.type = type
        self.source = source
        self.period = period
        self.offering = offering
    }
}

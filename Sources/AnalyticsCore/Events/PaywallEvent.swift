public struct PaywallEvent: AnalyticsEvent {

    public enum PurchaseEventType {
        case showSalesScreen
        case purchaseStarted
        case purchaseCompleted
        case purchaseCancelled
        case dismissUpgrade
        case restore
    }

    public var type: PurchaseEventType
    public var source: String?
    public var period: String?

    /// The RevenueCat offering the paywall was shown from, when the app runs more than one.
    /// Lets a promotional paywall's funnel be separated from the standard one in Mixpanel.
    public var offering: String?

    /// Event-specific properties, merged after the standard ones.
    public var extra: [String: Any]?

    public var name: String {
        let prefix = "[Paywall] "
        var suffix: String
        switch type {
            case .showSalesScreen:   suffix = "Shown"
            case .dismissUpgrade:    suffix = "Dismissed"
            case .restore:           suffix = "Purchase Restored"
            case .purchaseStarted:   suffix = "Purchase Started"
            case .purchaseCompleted: suffix = "Purchase Completed"
            case .purchaseCancelled: suffix = "Purchase Cancelled"
        }

        return prefix + suffix
    }

    public var properties: [String : Any]? {
        var props: [String: Any] = ["source": source ?? "--"]

        if let period {
            props["period"] = period
        }

        if let offering {
            props["offering"] = offering
        }

        if let extra {
            props.merge(extra) { _, new in new }
        }

        return props
    }

    public init(type: PurchaseEventType, source: String? = nil, period: String? = nil, offering: String? = nil, extra: [String: Any]? = nil) {
        self.type = type
        self.source = source
        self.period = period
        self.offering = offering
        self.extra = extra
    }
}

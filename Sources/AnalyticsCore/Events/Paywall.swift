public struct Paywall: AnalyticsEvent {

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

        return props
    }

    public init(type: PurchaseEventType, source: String? = nil, period: String? = nil) {
        self.type = type
        self.source = source
        self.period = period
    }
}


struct Paywall: AnalyticsEvent {

    enum PurchaseEventType {
        case showSalesScreen
        case purchaseStarted
        case purchaseCompleted
        case dismissUpgrade
        case restore
    }

    var type: PurchaseEventType
    var source: String?
    var period: String?

    var name: String {
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

    var properties: [String : Any]? {
        var props = ["source": source ?? "--" ]

        if type == .purchaseCompleted {
            if let period = period {
                props["period"] = period.description
            }
        }

        return props
    }
}

import Foundation

public struct PaymentUserProperty: AnalyticsUserProperty {
    public let name: String
    public let value: Any

    private init(name: String, value: Any) {
        self.name = name
        self.value = value
    }

    public static func tier(_ tier: String) -> PaymentUserProperty {
        PaymentUserProperty(name: "payment_tier", value: tier)
    }

    public static func pricingVariant(_ variant: String) -> PaymentUserProperty {
        PaymentUserProperty(name: "pricing_variant", value: variant)
    }
}

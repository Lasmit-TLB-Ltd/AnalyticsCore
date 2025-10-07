import Foundation

public struct SystemUserProperty: AnalyticsUserProperty {
    public let name: String
    public let value: Any

    private init(name: String, value: Any) {
        self.name = name
        self.value = value
    }

    public static func osVersion(_ majorVersion: Int) -> SystemUserProperty {
        SystemUserProperty(name: "os_version_major", value: majorVersion)
    }
}

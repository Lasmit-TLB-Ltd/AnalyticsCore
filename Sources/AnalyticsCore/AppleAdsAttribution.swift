import Foundation
import Mixpanel
import CocoaLumberjackSwift
#if canImport(AdServices)
import AdServices
#endif

/// Apple Ads attribution recorded as Mixpanel user properties for every install,
/// not only the ones RevenueCat later sends a subscription event for. (PGS-1256)
struct AppleAdsPayload: Decodable {
    let attribution: Bool
    let campaignId: Int?
    let adGroupId: Int?
    let keywordId: Int?
    let claimType: String?
    let conversionType: String?

    /// IDs are strings, like RevenueCat's, so Mixpanel lookup tables can match them.
    var properties: [String: MixpanelType] {
        var properties: [String: MixpanelType] = ["apple_ads_attributed": attribution]
        properties["apple_ads_campaign_id"] = campaignId.map(String.init)
        properties["apple_ads_ad_group_id"] = adGroupId.map(String.init)
        properties["apple_ads_keyword_id"] = keywordId.map(String.init) // absent for Search Match
        properties["apple_ads_claim_type"] = claimType
        properties["apple_ads_conversion_type"] = conversionType
        return properties
    }
}

#if canImport(AdServices)
extension AnalyticsManager {
    private static let appleAdsRecordedKey = "AnalyticsCore.appleAdsAttributionRecorded"

    /// Saves the install's Apple Ads attribution as `apple_ads_*` user properties, once per install.
    /// Call after `identify`, so the properties land on the identified profile.
    public static func recordAppleAdsAttribution() {
        guard !UserDefaults.standard.bool(forKey: appleAdsRecordedKey) else { return }
        guard #available(iOS 15, macOS 12, *) else { return }
        Task.detached(priority: .utility) { await fetchAppleAdsAttribution() }
    }

    @available(iOS 15, macOS 12, *)
    private static func fetchAppleAdsAttribution() async {
        guard let token = try? AAAttribution.attributionToken() else {
            DDLogInfo("[📍] No Apple Ads attribution token")
            return
        }
        var request = URLRequest(url: URL(string: "https://api-adservices.apple.com/api/v1/")!)
        request.httpMethod = "POST"
        request.setValue("text/plain", forHTTPHeaderField: "Content-Type")
        request.httpBody = Data(token.utf8)

        // Apple says a 404 straight after getting the token is normal: retry every 5 s, three attempts in all.
        for attempt in 1...3 {
            guard let (data, response) = try? await URLSession.shared.data(for: request),
                  let status = (response as? HTTPURLResponse)?.statusCode,
                  status != 500 else {
                DDLogWarn("[📍] Apple Ads attribution request failed; trying again next launch")
                return
            }
            if status == 404, attempt < 3 {
                try? await Task.sleep(nanoseconds: 5_000_000_000)
                continue
            }
            if status == 200, let payload = try? JSONDecoder().decode(AppleAdsPayload.self, from: data) {
                let properties = payload.properties
                Mixpanel.mainInstance().people.set(properties: properties)
                for (name, value) in properties.sorted(by: { $0.key < $1.key }) {
                    DDLogInfo("[📍] \(name) set to: \(value)")
                }
            } else {
                DDLogInfo("[📍] Apple Ads attribution answered \(status)")
            }
            UserDefaults.standard.set(true, forKey: appleAdsRecordedKey) // Apple answered; don't ask again
            return
        }
    }
}
#endif

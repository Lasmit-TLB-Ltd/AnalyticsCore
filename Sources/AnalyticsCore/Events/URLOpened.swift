import Foundation

struct URLOpened: AnalyticsEvent {

    var url: URL

    var name: String { "Visit URL" }

    var properties: [String : Any]? {
        ["url": url.description]
    }
}


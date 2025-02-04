import Foundation

public struct URLOpened: AnalyticsEvent {

    public var url: URL
    public var name: String { "Visit URL" }
    public var properties: [String : Any]? {
        ["url": url.description]
    }
    
    public init(url: URL) {
        self.url = url
    }
}


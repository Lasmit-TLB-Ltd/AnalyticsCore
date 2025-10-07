import Testing
@testable import AnalyticsCore

@Test func testOSVersionUserProperty() async throws {
    let property = SystemUserProperty.osVersion(18)

    #expect(property.name == "os_version_major")
    #expect(property.value as? Int == 18)
}

@Test func testOSVersionUserPropertyWithDifferentVersion() async throws {
    let property = SystemUserProperty.osVersion(17)

    #expect(property.name == "os_version_major")
    #expect(property.value as? Int == 17)
}

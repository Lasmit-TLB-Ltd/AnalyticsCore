import Testing
import Foundation
@testable import AnalyticsCore

/// Helper to clear UserDefaults and ensure synchronization for tests
func clearExperimentDefaults(_ key: String) {
    UserDefaults.standard.removeObject(forKey: key)
    UserDefaults.standard.synchronize()
}

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

// MARK: - Experiment Tests

enum TestExperiments: String {
    case testFeature
    case anotherFeature
    case thirdFeature
}

@Test func testExperimentBasicCreation() async throws {
    // Clear any previous test data
    clearExperimentDefaults("Experiment_testFeature")

    let experiment = Experiment(name: TestExperiments.testFeature)

    #expect(experiment.name == TestExperiments.testFeature)
    #expect(experiment.variant == .control || experiment.variant == .change)
}

@Test func testExperimentVariantPersistence() async throws {
    // Clear any previous test data
    clearExperimentDefaults("Experiment_anotherFeature")

    // Create first experiment instance
    let experiment1 = Experiment(name: TestExperiments.anotherFeature)
    let firstVariant = experiment1.variant

    // Create second experiment instance with same name
    let experiment2 = Experiment(name: TestExperiments.anotherFeature)
    let secondVariant = experiment2.variant

    // Should have the same variant
    #expect(firstVariant == secondVariant)
}

@Test func testExperimentManualVariantControl() async throws {
    // Clear any previous test data
    clearExperimentDefaults("Experiment_thirdFeature")

    // Create experiment with explicit control variant
    let experiment = Experiment(name: TestExperiments.thirdFeature, variant: .control)

    #expect(experiment.variant == .control)
    #expect(experiment.doNewThing == false)
}

@Test func testExperimentManualVariantChange() async throws {
    // Clear any previous test data
    clearExperimentDefaults("Experiment_thirdFeature")

    // Create experiment with explicit change variant
    let experiment = Experiment(name: TestExperiments.thirdFeature, variant: .change)

    #expect(experiment.variant == .change)
    #expect(experiment.doNewThing == true)
}

@Test func testExperimentManualVariantPersists() async throws {
    // Clear any previous test data
    clearExperimentDefaults("Experiment_thirdFeature")

    // Set explicit variant
    _ = Experiment(name: TestExperiments.thirdFeature, variant: .control)

    // Create new instance without specifying variant
    let experiment2 = Experiment(name: TestExperiments.thirdFeature)

    // Should use the persisted variant
    #expect(experiment2.variant == .control)
}

@Test func testExperimentDoNewThingProperty() async throws {
    let controlExperiment = Experiment(name: TestExperiments.testFeature, variant: .control)
    let changeExperiment = Experiment(name: TestExperiments.testFeature, variant: .change)

    #expect(controlExperiment.doNewThing == false)
    #expect(changeExperiment.doNewThing == true)
}

@Test func testExperimentDescription() async throws {
    let experiment = Experiment(name: TestExperiments.testFeature, variant: .control)

    #expect(experiment.description == "testFeature: control")
}

@Test func testMultipleExperimentsIndependent() async throws {
    // Clear any previous test data
    clearExperimentDefaults("Experiment_testFeature")
    clearExperimentDefaults("Experiment_anotherFeature")

    // Create two different experiments
    let experiment1 = Experiment(name: TestExperiments.testFeature, variant: .control)
    let experiment2 = Experiment(name: TestExperiments.anotherFeature, variant: .change)

    // They should maintain independent variants
    #expect(experiment1.variant == .control)
    #expect(experiment2.variant == .change)
}

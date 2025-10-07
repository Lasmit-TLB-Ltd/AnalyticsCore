# AnalyticsCore

A Swift Package Manager library that provides a simple, consistent way to track analytics across Lasmit iOS and watchOS applications.

## Overview

AnalyticsCore helps you avoid analytics bloat by focusing on key business events that move the needle:
- Onboarding flow
- Paywall interactions
- Feature usage
- Screen views

The explicit goal is track as little as possible to enable consistency, simplicity and reduced costs.

## Usage

### Setup

Initialize AnalyticsCore early in your app lifecycle (e.g., in your App struct or AppDelegate):

```swift
import AnalyticsCore

AnalyticsManager.shared.setup(apiKey: "your-amplitude-api-key")
```

### Tracking Events

#### Feature Usage

```swift
import AnalyticsCore

// Simple feature tracking
AnalyticsManager.shared.track(
    FeatureUse(title: "Timer Started")
)

// With additional properties
AnalyticsManager.shared.track(
    FeatureUse(
        title: "Workout Completed",
        properties: [
            "duration": 3600,
            "type": "strength"
        ]
    )
)
```

#### Paywall Events

```swift
// Paywall shown
AnalyticsManager.shared.track(
    Paywall.shown(source: "settings")
)

// Purchase completed
AnalyticsManager.shared.track(
    Paywall.purchaseCompleted(source: "onboarding", period: "annual")
)
```

#### Onboarding Flow

```swift
AnalyticsManager.shared.track(
    Onboarding.step("Welcome Screen")
)

AnalyticsManager.shared.track(
    Onboarding.step("Permissions")
)
```

#### Screen Views

```swift
AnalyticsManager.shared.track(
    ScreenView(name: "Settings")
)
```

Note: Amplitude automatically captures screen views by default, so manual tracking may not be necessary.

### User Properties

```swift
// Set user properties
AnalyticsManager.shared.setUserProperty(
    property: "subscription_type",
    value: "premium"
)
```

## Configuration

AnalyticsCore is configured for:
- **EU server zone**: Data is sent to Amplitude's EU servers
- **Automatic screen tracking**: Screen views are captured automatically by Amplitude
- **Debug mode**: Events are flushed immediately in DEBUG builds for easier testing
- **Logging**: All events are logged with CocoaLumberjack using the 📍 emoji prefix

## Event Naming Convention

Events follow a consistent naming convention with brackets:
- `[Paywall] Shown`
- `[Paywall] Purchase Completed`
- `[Onboarding] {step}`
- Feature usage events use the title you provide

## Development

### Building

```bash
swift build
```

### Running Tests

```bash
swift test
```

### Running a Single Test

```bash
swift test --filter <TestName>
```

## License

[Add your license here]

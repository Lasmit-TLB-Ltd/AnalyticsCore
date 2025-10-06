// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AnalyticsCore",
    platforms: [
           .iOS(.v15),
           .watchOS(.v9)
       ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "AnalyticsCore",
            targets: ["AnalyticsCore"]),
    ],
    dependencies: [
        .package(url: "https://github.com/amplitude/Amplitude-Swift", from: "1.0.0"),
        .package(url: "https://github.com/CocoaLumberjack/CocoaLumberjack", from: "3.9.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "AnalyticsCore",
            dependencies: [
                .product(name: "AmplitudeSwift", package: "Amplitude-Swift"),
                .product(name: "CocoaLumberjackSwift", package: "CocoaLumberjack")
            ]
        ),
        .testTarget(
            name: "AnalyticsCoreTests",
            dependencies: ["AnalyticsCore"]
        ),
    ]
)

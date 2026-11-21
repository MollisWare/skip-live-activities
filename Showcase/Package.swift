// swift-tools-version: 6.1
// This is a Skip (https://skip.dev) package: the Showcase app for skip-live-activities.
import PackageDescription

let package = Package(
    name: "showcase",
    defaultLocalization: "en",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "LiveActivitiesShowcase", type: .dynamic, targets: ["LiveActivitiesShowcase"]),
    ],
    dependencies: [
        .package(url: "https://github.com/skiptools/skip.git", from: "1.9.11"),
        .package(url: "https://github.com/skiptools/skip-ui.git", from: "1.0.0"),
        // the library under development, one folder up
        .package(path: "..")
    ],
    targets: [
        .target(name: "LiveActivitiesShowcase", dependencies: [
            .product(name: "SkipUI", package: "skip-ui"),
            .product(name: "SkipLiveActivities", package: "skip-live-activities")
        ], resources: [.process("Resources")], plugins: [.plugin(name: "skipstone", package: "skip")]),
    ]
)

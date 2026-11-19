// swift-tools-version: 6.1
// This is a Skip (https://skip.dev) package.
import PackageDescription

let package = Package(
    name: "skip-live-activities",
    defaultLocalization: "en",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        // Cross-platform manager and content model (iOS: ActivityKit, Android: notifications).
        .library(name: "SkipLiveActivities", targets: ["SkipLiveActivities"]),
        // iOS-only template views for the WidgetKit extension. Not transpiled by Skip.
        .library(name: "SkipLiveActivitiesUI", targets: ["SkipLiveActivitiesUI"]),
    ],
    dependencies: [
        .package(url: "https://source.skip.tools/skip.git", from: "1.0.0"),
        .package(url: "https://source.skip.tools/skip-kit.git", from: "1.0.0")
    ],
    targets: [
        .target(name: "SkipLiveActivities", dependencies: [
            .product(name: "SkipKit", package: "skip-kit")
        ], plugins: [.plugin(name: "skipstone", package: "skip")]),
        .target(name: "SkipLiveActivitiesUI", dependencies: [
            "SkipLiveActivities"
        ]),
        .testTarget(name: "SkipLiveActivitiesTests", dependencies: [
            "SkipLiveActivities",
            .product(name: "SkipTest", package: "skip")
        ], plugins: [.plugin(name: "skipstone", package: "skip")]),
    ]
)

if Context.environment["SKIP_BRIDGE"] ?? "0" != "0" {
    package.dependencies += [.package(url: "https://source.skip.tools/skip-bridge.git", "0.0.0"..<"2.0.0")]
    // only the Skip modules take part in bridging; the iOS-only UI target stays plain Swift
    package.targets.filter({ $0.name != "SkipLiveActivitiesUI" }).forEach({ target in
        target.dependencies += [.product(name: "SkipBridge", package: "skip-bridge")]
    })
    // all Skip library types must be dynamic to support bridging
    package.products = package.products.map({ product in
        guard let libraryProduct = product as? Product.Library, libraryProduct.name != "SkipLiveActivitiesUI" else { return product }
        return .library(name: libraryProduct.name, type: .dynamic, targets: libraryProduct.targets)
    })
}

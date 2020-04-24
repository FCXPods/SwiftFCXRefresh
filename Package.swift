// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftFCXRefresh",
    platforms: [.iOS(.v8)],
    products: [
        .library(
            name: "SwiftFCXRefresh",
            targets: ["SwiftFCXRefresh"]),
    ],
    targets: [
        .target(
            name: "SwiftFCXRefresh",
            path: "Sources"),
        .testTarget(
            name: "SwiftFCXRefreshTests",
            dependencies: ["SwiftFCXRefresh"]),
    ],
    swiftLanguageVersions: [.v5]
)

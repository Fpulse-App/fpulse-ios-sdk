// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FeedbackPulse",
    platforms: [
        .iOS(.v14),
        .macOS(.v11)
    ],
    products: [
        .library(
            name: "FeedbackPulse",
            targets: ["FeedbackPulse"]
        ),
    ],
    targets: [
        .target(
            name: "FeedbackPulse",
            dependencies: [],
            path: "Sources/FeedbackPulse"
        ),
        .testTarget(
            name: "FeedbackPulseTests",
            dependencies: ["FeedbackPulse"],
            path: "Tests/FeedbackPulseTests"
        ),
    ]
)

// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "Mocking",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(name: "Mocking", targets: ["Mocking"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "Mocking", dependencies: []),
        .testTarget(name: "MockingTests", dependencies: ["Mocking"]),
    ]
)

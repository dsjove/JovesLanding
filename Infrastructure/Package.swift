// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "Infrastructure",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
        .watchOS(.v9),
        .tvOS(.v13)
    ],
    products: [
        .library(
            name: "Infrastructure",
            targets: ["Infrastructure"]),
    ],
    dependencies: [
        .package(path: "../BTByJove")
    ],
    targets: [
        .target(
            name: "Infrastructure",
            dependencies: ["BTByJove"]),
        .testTarget(
            name: "InfrastructureTests",
            dependencies: ["Infrastructure"]),
    ]
)

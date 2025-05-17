// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "Infrastructure",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
        .watchOS(.v9),
        .tvOS(.v16)
    ],
    products: [
        .library(
            name: "Infrastructure",
            targets: ["Infrastructure"]),
    ],
    dependencies: [
        .package(path: "../../BLEByJove")
    ],
    targets: [
        .target(
            name: "Infrastructure",
            dependencies: ["BLEByJove"],
			exclude: ["OldTheJoveExpress"]),
        .testTarget(
            name: "InfrastructureTests",
            dependencies: ["Infrastructure"]),
    ]
)

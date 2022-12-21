// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "TrainsByJove",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
        .watchOS(.v9),
        .tvOS(.v13)
    ],
    products: [
        .library(
            name: "TrainsByJove",
            targets: ["TrainsByJove"]),
    ],
    dependencies: [
        .package(path: "../BTByJove")
    ],
    targets: [
        .target(
            name: "TrainsByJove",
            dependencies: ["BTByJove"]),
        .testTarget(
            name: "TrainsByJoveTests",
            dependencies: ["TrainsByJove"]),
    ]
)

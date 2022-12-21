// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "BTByJove",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
        .watchOS(.v9),
        .tvOS(.v13)
    ],
    products: [
        .library(
            name: "BTByJove",
            targets: ["BTByJove"]),
    ],
    dependencies: [
        .package(
			url: "https://github.com/apple/swift-collections.git",
			.upToNextMinor(from: "1.0.4") // or `.upToNextMajor
		)
    ],
    targets: [
        .target(
            name: "BTByJove",
            dependencies: [
				.product(name: "Collections", package: "swift-collections")
			]),
        .testTarget(
            name: "BTByJoveTests",
            dependencies: ["BTByJove"]),
    ]
)

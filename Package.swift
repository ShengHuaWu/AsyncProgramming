// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "AsyncProgramming",
    platforms: [.macOS(.v12)],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "AsyncProgramming",
            dependencies: [] /*,
            // This will trigger extra concurrency warnings
            swiftSettings: [
                .unsafeFlags([
                    "-Xfrontend", "-warn-concurrency",
                ]),
            ] */
        ),
        .testTarget(
            name: "AsyncProgrammingTests",
            dependencies: ["AsyncProgramming"]
        ),
    ]
)

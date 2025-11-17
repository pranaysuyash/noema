// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Noema",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "Noema",
            targets: ["Noema"]
        )
    ],
    dependencies: [
        // No external dependencies for privacy and control
        // All functionality built with native Apple frameworks
    ],
    targets: [
        .target(
            name: "Noema",
            dependencies: [],
            path: "Sources",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "NoemaTests",
            dependencies: ["Noema"],
            path: "Tests"
        )
    ]
)

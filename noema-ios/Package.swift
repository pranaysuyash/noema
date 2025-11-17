// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "noema",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "NoemaCore",
            targets: ["NoemaCore"]
        ),
        .library(
            name: "NoemaDomain",
            targets: ["NoemaDomain"]
        ),
        .library(
            name: "NoemaData",
            targets: ["NoemaData"]
        ),
        .library(
            name: "NoemaPresentation",
            targets: ["NoemaPresentation"]
        ),
    ],
    dependencies: [
        // Networking
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.8.0"),

        // Image loading and caching
        .package(url: "https://github.com/kean/Nuke.git", from: "12.0.0"),

        // Keychain wrapper
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess.git", from: "4.2.0"),

        // Markdown parsing
        .package(url: "https://github.com/apple/swift-markdown.git", from: "0.2.0"),

        // Analytics
        .package(url: "https://github.com/amplitude/Amplitude-Swift.git", from: "1.0.0"),

        // Testing frameworks
        .package(url: "https://github.com/Quick/Quick.git", from: "7.0.0"),
        .package(url: "https://github.com/Quick/Nimble.git", from: "12.0.0"),
    ],
    targets: [
        // MARK: - Core Targets

        .target(
            name: "NoemaCore",
            dependencies: []
        ),

        // MARK: - Domain Layer (Business Logic)

        .target(
            name: "NoemaDomain",
            dependencies: [
                "NoemaCore"
            ],
            path: "Sources/Domain"
        ),

        // MARK: - Data Layer (Repositories, Persistence)

        .target(
            name: "NoemaData",
            dependencies: [
                "NoemaDomain",
                "NoemaCore",
                "KeychainAccess",
            ],
            path: "Sources/Data"
        ),

        // MARK: - Presentation Layer (UI, ViewModels)

        .target(
            name: "NoemaPresentation",
            dependencies: [
                "NoemaDomain",
                "NoemaCore",
                "Nuke",
                .product(name: "Markdown", package: "swift-markdown"),
            ],
            path: "Sources/Presentation"
        ),

        // MARK: - Application Layer (Use Cases, Services)

        .target(
            name: "NoemaApplication",
            dependencies: [
                "NoemaDomain",
                "NoemaData",
                "NoemaCore",
                "Alamofire",
                .product(name: "AmplitudeSwift", package: "Amplitude-Swift"),
            ],
            path: "Sources/Application"
        ),

        // MARK: - AI Processing Layer

        .target(
            name: "NoemaAI",
            dependencies: [
                "NoemaDomain",
                "NoemaCore",
            ],
            path: "Sources/AIProcessing"
        ),

        // MARK: - Test Targets

        .testTarget(
            name: "NoemaDomainTests",
            dependencies: [
                "NoemaDomain",
                "Quick",
                "Nimble",
            ],
            path: "Tests/DomainTests"
        ),

        .testTarget(
            name: "NoemaDataTests",
            dependencies: [
                "NoemaData",
                "NoemaDomain",
                "Quick",
                "Nimble",
            ],
            path: "Tests/DataTests"
        ),

        .testTarget(
            name: "NoemaPresentationTests",
            dependencies: [
                "NoemaPresentation",
                "NoemaDomain",
                "Quick",
                "Nimble",
            ],
            path: "Tests/PresentationTests"
        ),

        .testTarget(
            name: "NoemaApplicationTests",
            dependencies: [
                "NoemaApplication",
                "NoemaDomain",
                "NoemaData",
                "Quick",
                "Nimble",
            ],
            path: "Tests/ApplicationTests"
        ),
    ]
)

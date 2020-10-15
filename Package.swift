// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TezosKit",
    platforms: [
        .macOS(.v10_12),
        .iOS(.v10)//,
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "TezosKit",
            targets: ["TezosKit"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/attaswift/BigInt",
            from: "5.2.0"
        ),
        .package(
            url: "https://github.com/newbdez33/MnemonicKit",
            from: "1.3.21"
        ),
        .package(
            url: "https://github.com/mxcl/PromiseKit",
            from: "6.13.3"
        ),
        .package(
            url: "https://github.com/keefertaylor/Base58Swift",
            from: "2.1.14"
        ),
        .package(
            url: "https://github.com/keefertaylor/secp256k1.swift",
            from: "8.0.6"
        ),
        .package(
            url: "https://github.com/krzyzanowskim/CryptoSwift",
            from: "1.3.2"
        ),
        .package(
            name: "Sodium",
            url: "https://github.com/jedisct1/swift-sodium",
            .branch("master")
        )
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "TezosKit",
            dependencies: ["BigInt", "MnemonicKit", "Sodium", "CryptoSwift", "secp256k1", "Base58Swift", "PromiseKit"],
            path: "TezosKit",
            exclude: ["TezosKit/Info.plist", "Examples", "docs"])
    ]
)

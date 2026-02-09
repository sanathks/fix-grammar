// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "FixGrammar",
    platforms: [
        .macOS(.v13)
    ],
    targets: [
        .executableTarget(
            name: "FixGrammar",
            path: "Sources/FixGrammar"
        )
    ]
)

// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "MultiLogging",
    products: [
        .library(name: "MultiLogging", targets: ["MultiLogging"])
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.5")
    ],
    targets: [
      .target(name: "MultiLogging", dependencies: ["Vapor"]),
      .target(name: "LoggingExample", dependencies: ["MultiLogging"])
    ]
)

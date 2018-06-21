// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "VaporLogging",
    products: [
        .library(name: "VaporLogging", targets: ["VaporLogging"])
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.5")
    ],
    targets: [
      .target(name: "VaporLogging", dependencies: ["Vapor"]),
      .target(name: "LoggingExample", dependencies: ["VaporLogging"])
    ]
)

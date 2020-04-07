// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "tableschema-swift",
    products: [
        .library(name: "TableSchema", type: .static, targets: ["TableSchema"])
    ],
    dependencies: [],
    targets: [
        .target(name: "TableSchema", dependencies: [], path: "Sources"),
        .testTarget(name: "TableSchemaTests", dependencies: ["TableSchema"])
    ],
    swiftLanguageVersions: [.version("4.2")]
)

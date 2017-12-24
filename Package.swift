// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "locations-server",
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", .upToNextMajor(from: "2.1.0")),
        .package(url: "https://github.com/vapor/auth-provider.git", .upToNextMajor(from: "1.2.0")),
        .package(url: "https://github.com/vapor/fluent-provider.git", .upToNextMajor(from: "1.2.0")),
        .package(url: "https://github.com/vapor-community/postgresql-provider.git", .upToNextMajor(from: "2.1.0")),
        .package(url: "https://github.com/aonawale/JSONAPISerializer", .upToNextMajor(from: "1.2.2") )
    ],
    targets: [
        .target(name: "App", dependencies: ["Vapor", "AuthProvider", "FluentProvider", "PostgreSQLProvider", "JSONAPISerializer"],
                exclude: [
                    "Config",
                    "Public",
                    "Resources",
                    ]),
        .target(name: "Run", dependencies: ["App"])
    ]
)

// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "ayabar",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "ayabar", targets: ["ayabar"])
    ],
    targets: [
        .executableTarget(
            name: "ayabar",
            path: "Sources/ayabar"
        )
    ]
)

// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PipUpTVOS",
    platforms: [
        .tvOS(.v17)
    ],
    products: [
        .library(
            name: "PipUpTVOS",
            targets: ["PipUpTVOS"]
        ),
    ],
    dependencies: [
        // Add any external dependencies here
    ],
    targets: [
        .target(
            name: "PipUpTVOS",
            dependencies: [],
            path: "PipUpTVOS",
            exclude: ["Info.plist", "Assets.xcassets"]
        ),
        .testTarget(
            name: "PipUpTVOSTests",
            dependencies: ["PipUpTVOS"],
            path: "PipUpTVOSTests"
        ),
    ]
)
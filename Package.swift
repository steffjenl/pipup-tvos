// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PipUpTVOS",
    platforms: [
        .tvOS(.v15)
    ],
    products: [
        .library(
            name: "PipUpTVOS",
            targets: ["PipUpTVOS"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/httpswift/swifter.git", from: "1.5.0")
    ],
    targets: [
        .target(
            name: "PipUpTVOS",
            dependencies: [
                .product(name: "Swifter", package: "swifter")
            ]
        ),
        .testTarget(
            name: "PipUpTVOSTests",
            dependencies: ["PipUpTVOS"]
        ),
    ]
)
// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "DeepFacedMac",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "DeepFacedMac", targets: ["DeepFacedMac"])
    ],
    targets: [
        .executableTarget(
            name: "DeepFacedMac",
            dependencies: ["DeepFacedVirtualCamera"]
        ),
        .target(name: "DeepFacedVirtualCamera")
    ]
)

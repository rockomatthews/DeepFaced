// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "DeepFacedMac",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "DeepFacedMac", targets: ["DeepFacedMac"]),
        .executable(name: "DeepFacedCameraExtension", targets: ["DeepFacedCameraExtension"])
    ],
    targets: [
        .executableTarget(
            name: "DeepFacedMac",
            dependencies: ["DeepFacedVirtualCamera"]
        ),
        .executableTarget(
            name: "DeepFacedCameraExtension",
            dependencies: ["DeepFacedVirtualCamera"]
        ),
        .target(name: "DeepFacedVirtualCamera")
    ]
)

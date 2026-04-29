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
    dependencies: [
        .package(url: "https://github.com/DeepARSDK/swift-deepar", branch: "main")
    ],
    targets: [
        .executableTarget(
            name: "DeepFacedMac",
            dependencies: [
                "DeepFacedVirtualCamera",
                .product(name: "DeepAR", package: "swift-deepar")
            ]
        ),
        .executableTarget(
            name: "DeepFacedCameraExtension",
            dependencies: ["DeepFacedVirtualCamera"]
        ),
        .target(name: "DeepFacedVirtualCamera")
    ]
)

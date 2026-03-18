// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "VFXCtrl",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "VFXCtrl", targets: ["VFXCtrl"]),
    ],
    targets: [
        .executableTarget(
            name: "VFXCtrl",
            path: "src",
            linkerSettings: [.linkedFramework("CoreMIDI")]
        ),
        .testTarget(
            name: "VFXCtrlTests",
            dependencies: ["VFXCtrl"],
            path: "Tests/VFXCtrlTests"
        ),
    ]
)

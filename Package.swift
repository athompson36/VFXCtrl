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
            resources: [
                .copy("Resources/VFX_SD_GOTEK_CATALOG.csv"),
            ],
            linkerSettings: [.linkedFramework("CoreMIDI")]
        ),
        .testTarget(
            name: "VFXCtrlTests",
            dependencies: ["VFXCtrl"],
            path: "Tests/VFXCtrlTests"
        ),
    ]
)

// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "flutter_sharing_intent",
    platforms: [
        .iOS(.v12),
    ],
    products: [
        .library(name: "flutter_sharing_intent", targets: ["flutter_sharing_intent"]),
    ],
    targets: [
        .target(
            name: "flutter_sharing_intent",
            dependencies: [],
            path: ".",
            exclude: [
                "Assets",
                "Example",
                "Tests",
                "flutter_sharing_intent.podspec",
                ".gitignore",
                "Podfile",
            ],
            sources: ["Classes"],
            resources: [
                .process("Resources/PrivacyInfo.xcprivacy"),
            ],
            publicHeadersPath: "Classes",
            cSettings: [
                .headerSearchPath("Classes"),
            ]
        ),
    ]
)

// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "XeroKit",
    platforms: [
        .tvOS   (.v18),
        .iOS    ("17.6"),
        .macOS  (.v13),
        .macCatalyst(.v18)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Xero",
            targets: ["Xero"]
        ),
    ],
    dependencies: [
        .Tapioca
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Xero",
            dependencies: [
                .Tapioca
            ]
        ),

    ]
)
extension String {
    static let Tapioca = "https://github.com/Project-Academy/Tapioca.git"
}
extension Package.Dependency {
    static var Tapioca: Package.Dependency { .package(url: .Tapioca, from: "1.0.0") }
}
extension Target.Dependency {
    static var Tapioca: Target.Dependency { .product(name: "Tapioca", package: "Tapioca") }
}


// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "NotesArchive",
    platforms: [ .macOS(.v11) ],
    products: [
        .library(
            name: "NotesArchive",
            targets: [ "NotesArchive" ])
    ],
    targets: [
        .target(name: "NotesArchive")
    ]
)

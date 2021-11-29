import Foundation
import UniformTypeIdentifiers

public struct Archive: NotesSerializable {
    public static var contentType: UTType { UTType(importedAs: "com.apple.notes.archive", conformingTo: .package) }

    public struct Metadata: Codable {
        public struct Creator: Codable {
            public var softwareVersionName: String?
            public var softwareIdentifier: String?
            public var softwareVersion: String?
            public init() {}
        }

        @EncodedAsTypeIdentifier private(set) public var typeIdentifier = Archive.contentType
        private(set) public var revision = 1
        public var createdAt: Date
        public var createdBy: Creator?
        public var folderIdentifiers: [Folder.Metadata.Identifier]

        public init(createdAt: Date = Date(), createdBy: Creator? = nil, folderIdentifiers: [Folder.Metadata.Identifier] = []) {
            self.createdAt = createdAt
            self.createdBy = createdBy
            self.folderIdentifiers = folderIdentifiers
        }
    }

    var originalContentsURL: URL?
    public var metadata: Metadata
    public var folders: [Folder]

    public init(metadata: Metadata = Metadata(), folders: [Folder] = []) {
        self.metadata = metadata
        self.folders = folders
    }

    public init(contentsOf url: URL) throws {
        try self.init(from: FileWrapper(url: url))
        originalContentsURL = url
    }

    public func write(to url: URL) throws {
        try fileWrapper().write(to: url, options: .atomic, originalContentsURL: originalContentsURL)
    }

    func fileWrapper() throws -> FileWrapper {
        var updated = self
        updated.metadata.folderIdentifiers = folders.map(\.metadata.identifier)
        let fileWrapper = try FileWrapper(notesPackageWith: updated)
        try fileWrapper.encode(folders)
        return fileWrapper
    }

    init(from fileWrapper: FileWrapper) throws {
        metadata = try fileWrapper.decodeNotesPackage(Metadata.self)
        folders = try fileWrapper.decode([Folder].self)
    }
}

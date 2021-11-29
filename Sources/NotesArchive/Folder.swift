import Foundation
import UniformTypeIdentifiers

public struct Folder: NotesSerializable {
    public static var contentType: UTType { UTType(importedAs: "com.apple.notes.folder", conformingTo: .package) }
    public static let pathExtension = "folder"

    public struct Metadata: Codable {
        public enum Identifier: Hashable, RawRepresentable, Codable {
            case `default`
            case quickNotes
            case custom(UUID)

            enum Special: String, Codable {
                case `default` = "DefaultFolder-CloudKit"
                case quickNotes = "SystemPaper-CloudKit"
            }

            public init?(rawValue: String) {
                switch Special(rawValue: rawValue) {
                case .default:
                    self = .default
                case .quickNotes:
                    self = .quickNotes
                case nil:
                    guard let uuid = UUID(uuidString: rawValue) else { return nil }
                    self = .custom(uuid)
                }
            }

            public var rawValue: String {
                switch self {
                case .default:
                    return Special.default.rawValue
                case .quickNotes:
                    return Special.quickNotes.rawValue
                case .custom(let uuid):
                    return uuid.uuidString
                }
            }
        }

        public struct Sorting: Codable {
            public enum Order: String, Codable {
                case createdAt = "CREATED_AT"
                case modifiedAt = "MODIFIED_AT"
                case title = "TITLE"
            }

            public enum Direction: String, Codable {
                case ascending = "ASCENDING"
                case descending = "DESCENDING"
            }

            public var order: Order
            public var direction: Direction

            public init(order: Order, direction: Direction) {
                self.order = order
                self.direction = direction
            }
        }

        @EncodedAsTypeIdentifier private(set) public var typeIdentifier = Folder.contentType
        public var identifier: Identifier
        public var title: String
        public var noteSorting: Sorting?
        public var subfolderIdentifiers: [Identifier]

        public init(identifier: Identifier = .custom(UUID()), title: String, noteSorting: Sorting? = nil, subfolderIdentifiers: [Identifier] = []) {
            self.identifier = identifier
            self.title = title
            self.noteSorting = noteSorting
            self.subfolderIdentifiers = subfolderIdentifiers
        }
    }
    
    public var metadata: Metadata
    public var subfolders: [Folder]
    public var notes: [Note]

    public init(metadata: Metadata, subfolders: [Folder] = [], notes: [Note] = []) {
        self.metadata = metadata
        self.subfolders = subfolders
        self.notes = notes
    }

    var preferredName: String? {
        metadata.title
    }

    func fileWrapper() throws -> FileWrapper {
        var updated = self
        updated.metadata.subfolderIdentifiers = subfolders.map(\.metadata.identifier)
        let fileWrapper = try FileWrapper(notesPackageWith: updated)
        try fileWrapper.encode(subfolders)
        try fileWrapper.encode(notes)
        return fileWrapper
    }

    init(from fileWrapper: FileWrapper) throws {
        metadata = try fileWrapper.decodeNotesPackage(Metadata.self)
        subfolders = try fileWrapper.decode([Folder].self)
        notes = try fileWrapper.decode([Note].self)
    }
}

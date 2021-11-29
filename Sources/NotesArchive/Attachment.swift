import CoreGraphics
import Foundation
import UniformTypeIdentifiers

public struct Attachment: NotesSerializable {
    public static var contentType: UTType { UTType(importedAs: "com.apple.notes.attachment", conformingTo: .compositeContent) }
    public static let pathExtension = "attachment"

    public struct Metadata: Codable {
        public enum ContentType {
            public static var table: UTType { UTType(importedAs: "com.apple.notes.table", conformingTo: .content) }
            public static var gallery: UTType { UTType(importedAs: "com.apple.notes.gallery", conformingTo: .content) }
            public static var sketch: UTType { UTType(importedAs: "com.apple.notes.sketch", conformingTo: .content) }
            public static var drawing: UTType { UTType(importedAs: "com.apple.drawing.2", conformingTo: .content) }
        }

        public struct Cropping: Codable {
            public var bottomRight: CGPoint
            public var topRight: CGPoint
            public var topLeft: CGPoint
            public var bottomLeft: CGPoint

            public init(bottomRight: CGPoint, topRight: CGPoint, topLeft: CGPoint, bottomLeft: CGPoint) {
                self.bottomRight = bottomRight
                self.topRight = topRight
                self.topLeft = topLeft
                self.bottomLeft = bottomLeft
            }
        }

        public enum Orientation: String, Codable {
            case down = "DOWN"
            case left = "LEFT"
            case right = "RIGHT"
        }

        public enum ImageFilter: String, Codable {
            case color = "COLOR"
            case grayscale = "GRAYSCALE"
            case blackAndWhite = "BLACK_AND_WHITE"
            case whiteboard = "WHITEBOARD"
        }

        @EncodedAsTypeIdentifier private(set) public var typeIdentifier = Attachment.contentType
        public var identifier: UUID
        @EncodedAsTypeIdentifier public var attachmentTypeIdentifier: UTType
        public var mediaFilename: String?
        public var createdAt: Date
        @ClampedDate public var modifiedAt: Date
        public var title: String?
        public var bounds: CGRect?
        public var cropping: Cropping?
        public var orientation: Orientation?
        public var imageFilter: ImageFilter?
        public var url: URL?
        public var rows: [[Note.Content]]?
        public var isRightToLeft: Bool?
        public var subattachmentIdentifiers: [UUID]?

        internal init(identifier: UUID = UUID(), attachmentTypeIdentifier: UTType, mediaFilename: String? = nil, createdAt: Date = Date(), modifiedAt: Date = Date(), title: String? = nil, bounds: CGRect? = nil, cropping: Cropping? = nil, orientation: Orientation? = nil, imageFilter: ImageFilter? = nil, url: URL? = nil, rows: [[Note.Content]]? = nil, isRightToLeft: Bool? = nil, subattachmentIdentifiers: [UUID]? = nil) {
            self.identifier = identifier
            self.attachmentTypeIdentifier = attachmentTypeIdentifier
            self.mediaFilename = mediaFilename
            self.createdAt = createdAt
            self.modifiedAt = modifiedAt
            self.title = title
            self.bounds = bounds
            self.cropping = cropping
            self.orientation = orientation
            self.imageFilter = imageFilter
            self.url = url
            self.rows = rows
            self.isRightToLeft = isRightToLeft
            self.subattachmentIdentifiers = subattachmentIdentifiers
        }
    }


    public var metadata: Metadata
    public var subattachments: [Attachment]

    var contents: FileWrapper?

    public init(metadata: Metadata, subattachments: [Attachment] = []) {
        self.metadata = metadata
        self.subattachments = subattachments
    }

    var preferredName: String? {
        metadata.mediaFilename ?? metadata.title
    }

    func fileWrapper() throws -> FileWrapper {
        var updated = self
        updated.metadata.mediaFilename = contents?.preferredFilename
        updated.metadata.subattachmentIdentifiers = subattachments.map(\.metadata.identifier)
        let fileWrapper = try FileWrapper(notesPackageWith: updated)

        if let contents = contents {
            fileWrapper.addFileWrapper(contents)
        }

        try fileWrapper.encode(subattachments)

        return fileWrapper
    }

    init(from fileWrapper: FileWrapper) throws {
        metadata = try fileWrapper.decodeNotesPackage(Metadata.self)
        subattachments = try fileWrapper.decode([Attachment].self)
        contents = metadata.mediaFilename.flatMap { fileWrapper.fileWrappers?[$0] }
    }
}

public extension Attachment {
    static func link(to url: URL?, title: String? = nil) -> Attachment {
        Attachment(metadata: Metadata(attachmentTypeIdentifier: .url, title: title, url: url))
    }

    mutating func setContents(from url: URL) throws {
        let fileWrapper = try FileWrapper(url: url)
        guard fileWrapper.isRegularFile else {
            throw CocoaError.error(.fileReadUnknown, url: url)
        }
        contents = fileWrapper
    }

    mutating func setContents(from data: Data, filename: String) {
        let fileWrapper = FileWrapper(regularFileWithContents: data)
        fileWrapper.preferredFilename = filename
        contents = fileWrapper
    }
}

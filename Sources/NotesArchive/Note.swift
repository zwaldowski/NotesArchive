import Foundation
import UniformTypeIdentifiers

public struct Note: NotesSerializable {
    public static var contentType: UTType { UTType(importedAs: "com.apple.notes.note", conformingTo: .package) }

    public struct Metadata: Codable {
        public enum PaperStyle: String, Codable {
            case none = "NONE"
            case smallGrid = "SMALL_GRID"
            case mediumGrid = "MEDIUM_GRID"
            case largeGrid = "LARGE_GRID"
            case smallLines = "SMALL_LINES"
            case mediumLines = "MEDIUM_LINES"
            case largeLines = "LARGE_LINES"
        }

        public enum Background: String, Codable {
            case `default` = "DEFAULT"
            case light = "LIGHT"
        }

        public enum AttachmentViewType: String, Codable {
            case preview = "PREVIEW"
            case thumbnail = "THUMBNAIL"
        }

        public struct EncryptedData: Codable {
            public var iterationCount: Int64
            public var salt: Data
            public var initializationVector: Data
            public var tag: Data
            public var wrappedKey: Data
            public var passwordHint: String
            public var data: Data?
        }

        public var identifier: UUID
        @EncodedAsTypeIdentifier private(set) var typeIdentifier = Note.contentType
        public var createdAt: Date
        @ClampedDate public var modifiedAt: Date
        public var title: String?
        public var isPinned: Bool
        public var paperStyle: PaperStyle?
        public var preferredBackground: Background?
        public var attachmentViewType: AttachmentViewType
        public var encryptedData: EncryptedData?
        public var content: Content!

        public init(identifier: UUID = UUID(), createdAt: Date = Date(), modifiedAt: Date = Date(), title: String? = nil, isPinned: Bool = false, paperStyle: PaperStyle? = nil, preferredBackground: Background? = nil, attachmentViewType: AttachmentViewType = .preview, encryptedData: EncryptedData? = nil, content: Content? = nil) {
            self.identifier = identifier
            self.createdAt = createdAt
            self.modifiedAt = modifiedAt
            self.title = title
            self.isPinned = isPinned
            self.paperStyle = paperStyle
            self.preferredBackground = preferredBackground
            self.attachmentViewType = attachmentViewType
            self.encryptedData = encryptedData
            self.content = content
        }
    }

    public struct Content: Codable {
        public struct Range: Codable {
            public var startsAt: Int
            public var length: Int

            public init(startsAt: Int = 0, length: Int = 0) {
                self.startsAt = startsAt
                self.length = length
            }
        }

        public enum WritingDirection: String, Codable {
            case natural = "NATURAL"
            case leftToRight = "LEFT_TO_RIGHT"
            case leftToRightOverride = "LEFT_TO_RIGHT_OVERRIDE"
            case rightToLeft = "RIGHT_TO_LEFT"
            case rightToLeftOverride = "RIGHT_TO_LEFT_OVERRIDE"
        }

        public struct Font: Codable {
            public var name: String?
            public var pointSize: CGFloat?
            public var isBold: Bool?
            public var isItalic: Bool?
            public var isUnderline: Bool?
            public var isStrikethrough: Bool?
            public var superscript: Superscript?
            public var color: Color?

            public init(name: String? = nil, pointSize: CGFloat? = nil, isBold: Bool? = nil, isItalic: Bool? = nil, isUnderline: Bool? = nil, isStrikethrough: Bool? = nil, superscript: Superscript? = nil, color: Color? = nil) {
                self.name = name
                self.pointSize = pointSize
                self.isBold = isBold
                self.isItalic = isItalic
                self.isUnderline = isUnderline
                self.isStrikethrough = isStrikethrough
                self.superscript = superscript
                self.color = color
            }
        }

        public struct ParagraphStyle: Codable {
            public enum Name: String, Codable {
                case title = "TITLE"
                case heading = "HEADING"
                case subheading = "SUBHEADING"
                case body = "BODY"
                case caption = "CAPTION"
                case monospaced = "MONOSPACED"
                case bulletList = "BULLET_LIST"
                case dashedList = "DASHED_LIST"
                case numberedList = "NUMBERED_LIST"
                case checklist = "CHECKLIST"
            }

            public enum Alignment: String, Codable {
                case natural = "NATURAL"
                case center = "CENTER"
                case right = "RIGHT"
                case left = "LEFT"
                case justified = "JUSTIFIED"
            }

            public var name: Name
            public var alignment = Alignment.natural
            public var indent = 0
            public var startingItemNumber: Int?
            public var checklistItem: ChecklistItem?

            public init(name: Name = .body, alignment: Alignment = .natural, indent: Int = 0, startingItemNumber: Int? = nil, checklistItem: ChecklistItem? = nil) {
                self.name = name
                self.alignment = alignment
                self.indent = indent
                self.startingItemNumber = startingItemNumber
                self.checklistItem = checklistItem
            }
        }

        public struct InlineAttachment: Codable {
            public enum TypeIdentifier {
                public static var unknown: UTType { UTType(importedAs: "com.apple.notes.inlinetextattachment", conformingTo: .content) }
                public static var mention: UTType { UTType(importedAs: "com.apple.notes.inlinetextattachment.mention", conformingTo: unknown) }
                public static var hashtag: UTType { UTType(importedAs: "com.apple.notes.inlinetextattachment.hashtag", conformingTo: unknown) }
            }

            public var identifier: UUID
            public var contentIdentifier: String?
            public var altText: String?
            @EncodedAsTypeIdentifier public var attachmentTypeIdentifier: UTType
            public var createdAt: Date

            public init(identifier: UUID = UUID(), contentIdentifier: String? = nil, altText: String? = nil, attachmentTypeIdentifier: UTType, createdAt: Date) {
                self.identifier = identifier
                self.contentIdentifier = contentIdentifier
                self.altText = altText
                self.attachmentTypeIdentifier = attachmentTypeIdentifier
                self.createdAt = createdAt
            }
        }

        public enum Superscript: Int, Codable {
            case superscript = 1
            case useDefault = 0
            case `subscript` = -1
        }

        public struct Color: Codable {
            @EncodedAsColorSpaceName public var space: CGColorSpace
            public var components: [Double]

            public init(space: CGColorSpace, components: [Double]) {
                self.space = space
                self.components = components
            }
        }

        public struct ChecklistItem: Codable {
            public var identifier: UUID
            public var isDone: Bool

            public init(identifier: UUID = UUID(), isDone: Bool = false) {
                self.identifier = identifier
                self.isDone = isDone
            }
        }

        public struct Attribute: Codable {
            public var range: Range
            public var font: Font?
            public var paragraphStyle: ParagraphStyle?
            public var link: URL?
            public var writingDirection: WritingDirection?
            public var attachmentIdentifier: UUID?
            public var inlineAttachment: InlineAttachment?

            public init(range: Range, font: Font? = nil, paragraphStyle: ParagraphStyle? = nil, link: URL? = nil, writingDirection: WritingDirection? = nil, attachmentIdentifier: UUID? = nil, inlineAttachment: InlineAttachment? = nil) {
                self.range = range
                self.font = font
                self.paragraphStyle = paragraphStyle
                self.link = link
                self.writingDirection = writingDirection
                self.attachmentIdentifier = attachmentIdentifier
                self.inlineAttachment = inlineAttachment
            }
        }

        public var text: String
        public var attributes: [Attribute]

        public init(text: String = "", attributes: [Attribute] = []) {
            self.text = text
            self.attributes = attributes
        }
    }

    public var metadata: Metadata
    public var attachments: [Attachment]

    public var preferredName: String? { metadata.content.text }

    public init(metadata: Metadata, attachments: [Attachment] = []) {
        self.metadata = metadata
        self.attachments = attachments
    }

    func fileWrapper() throws -> FileWrapper {
        let fileWrapper = try FileWrapper(notesPackageWith: self)
        try fileWrapper.encode(attachments)
        return fileWrapper
    }

    init(from fileWrapper: FileWrapper) throws {
        metadata = try fileWrapper.decodeNotesPackage(Metadata.self)
        attachments = try fileWrapper.decode([Attachment].self)
    }
}

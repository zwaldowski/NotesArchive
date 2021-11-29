import Foundation
import UniformTypeIdentifiers

protocol NotesSerializable {
    static var contentType: UTType { get }
    static var pathExtension: String { get }

    associatedtype Metadata
    var metadata: Metadata { get }
    var preferredName: String? { get }

    init(from fileWrapper: FileWrapper) throws
    func fileWrapper() throws -> FileWrapper
}

extension NotesSerializable {
    public static var pathExtension: String {
        contentType.preferredFilenameExtension!
    }

    var preferredName: String? {
        nil
    }

    var pathComponent: String {
        if let name = preferredName?.sanitizedFilename, !name.isEmpty {
            return name
        } else {
            return "\(Self.self)"
        }
    }
}

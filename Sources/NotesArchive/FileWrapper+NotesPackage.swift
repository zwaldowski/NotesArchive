import Foundation

extension FileWrapper {
    func nameForAppendingFileWrapper(pathComponent: String, pathExtension: String, attempt: Int = 1) -> String {
        var url = FileManager.default.temporaryDirectory
        url.appendPathComponent(
            attempt > 1 ? "\(pathComponent) \(attempt)" : pathComponent,
            isDirectory: false)
        url.appendPathExtension(pathExtension)
        let filename = url.lastPathComponent
        guard fileWrappers?[filename] == nil else {
            return nameForAppendingFileWrapper(pathComponent: pathComponent, pathExtension: pathExtension, attempt: attempt + 1)
        }
        return filename
    }

    convenience init<T>(notesPackageWith value: T) throws where T: NotesSerializable, T.Metadata: Encodable {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let infoFileContents = try encoder.encode(value.metadata)
        let infoFile = FileWrapper(regularFileWithContents: infoFileContents)
        self.init(directoryWithFileWrappers: [ "info.json": infoFile ])
    }

    func decodeNotesPackage<T>(_: T.Type) throws -> T where T: Decodable {
        guard isDirectory, let infoFile = fileWrappers?["info.json"], infoFile.isRegularFile, let infoData = infoFile.regularFileContents else {
            throw CocoaError.error(.fileReadUnknown)
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(T.self, from: infoData)
    }

    func encode<T>(_ children: [T]) throws where T: NotesSerializable, T.Metadata: Encodable {
        for child in children {
            let fileWrapper = try child.fileWrapper()
            fileWrapper.preferredFilename = nameForAppendingFileWrapper(pathComponent: child.pathComponent, pathExtension: T.pathExtension)
            addFileWrapper(fileWrapper)
        }
    }

    func decode<T>(_: [T].Type) throws -> [T] where T: NotesSerializable, T.Metadata: Encodable {
        guard let fileWrappers = fileWrappers else { return [] }
        let suffix = ".\(T.pathExtension)"
        return try fileWrappers
            .filter { $0.key.hasSuffix(suffix) }
            .map { try T(from: $0.value) }
    }
}

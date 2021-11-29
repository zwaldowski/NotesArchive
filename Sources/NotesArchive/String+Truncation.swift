import Foundation

let filenameIllegal = Set<Character>(["/", "\\", "?", "%", "*", "|", "<", ">", ":", "\u{fffc}"])

extension Character {
    var isAllowedInFilename: Bool {
        !filenameIllegal.contains(self)
    }
}

extension String {
    var sanitizedFilename: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
            .drop { $0 == "." }
            .prefix { !$0.isNewline }
            .filter(\.isAllowedInFilename)
            .truncated(maxUTF16Length: 128)
    }

    func truncated(maxUTF16Length: Int) -> String {
        let prefix = utf16.prefix(maxUTF16Length)
        let isTruncated = prefix.endIndex != endIndex
        guard let string = String(prefix) else { return truncated(maxUTF16Length: maxUTF16Length - 1) }
        return isTruncated ? "\(string)…" : string
    }
}

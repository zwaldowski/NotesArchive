import UniformTypeIdentifiers

@propertyWrapper @frozen
public struct EncodedAsTypeIdentifier: Hashable, Codable {
    public var wrappedValue: UTType

    public init(wrappedValue: UTType) {
        self.wrappedValue = wrappedValue
    }

    public init(from decoder: Decoder) throws {
        let identifier = try decoder.singleValueContainer().decode(String.self)
        wrappedValue = UTType(importedAs: identifier, conformingTo: .content)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(wrappedValue.identifier)
    }
}

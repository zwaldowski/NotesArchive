import CoreGraphics

@propertyWrapper @frozen
public struct EncodedAsColorSpaceName: Hashable, RawRepresentable, Codable {
    public var wrappedValue: CGColorSpace

    public init(wrappedValue: CGColorSpace) {
        self.wrappedValue = wrappedValue
    }

    public init?(rawValue: String) {
        guard let wrappedValue = CGColorSpace(name: rawValue as CFString) else { return nil }
        self.wrappedValue = wrappedValue
    }

    public var rawValue: String {
        wrappedValue.name! as String
    }
}

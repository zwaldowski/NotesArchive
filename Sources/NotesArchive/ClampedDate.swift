import Foundation

@propertyWrapper @frozen
public struct ClampedDate: Codable {
    var clampedValue: Date

    public init(wrappedValue: Date) {
        self.clampedValue = Self.clamp(wrappedValue)
    }

    public var wrappedValue: Date {
        get { clampedValue }
        set { clampedValue = Self.clamp(newValue) }
    }

    public init(from decoder: Decoder) throws {
        let date = try decoder.singleValueContainer().decode(Date.self)
        self.init(wrappedValue: date)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(wrappedValue)
    }

    static func clamp(_ date: Date) -> Date {
        date > .distantPast && date < .distantFuture ? date : Date()
    }
}

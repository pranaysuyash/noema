import Foundation

/// Represents a named entity extracted from note content (person, place, organization, etc.)
public struct NamedEntity: Identifiable, Equatable, Codable, Sendable, Hashable {
    // MARK: - Properties

    public let id: UUID
    public let text: String // The entity text (e.g., "Steve Jobs")
    public let type: EntityType
    public let confidence: Float
    public let startIndex: Int // Character position in original text
    public let endIndex: Int

    // MARK: - Initialization

    public init(
        id: UUID = UUID(),
        text: String,
        type: EntityType,
        confidence: Float,
        startIndex: Int,
        endIndex: Int
    ) {
        self.id = id
        self.text = text
        self.type = type
        self.confidence = min(1.0, max(0.0, confidence))
        self.startIndex = startIndex
        self.endIndex = endIndex
    }

    // MARK: - Computed Properties

    public var isHighConfidence: Bool {
        confidence >= 0.85
    }

    public var length: Int {
        endIndex - startIndex
    }
}

/// Types of named entities that can be recognized
public enum EntityType: String, Codable, Sendable, CaseIterable {
    case person
    case place
    case organization
    case date
    case time
    case money
    case percentage
    case custom

    public var label: String {
        rawValue.capitalized
    }

    public var iconName: String {
        switch self {
        case .person:
            return "person.fill"
        case .place:
            return "location.fill"
        case .organization:
            return "building.2.fill"
        case .date:
            return "calendar"
        case .time:
            return "clock.fill"
        case .money:
            return "dollarsign.circle.fill"
        case .percentage:
            return "percent"
        case .custom:
            return "tag.fill"
        }
    }

    public var colorHex: String {
        switch self {
        case .person:
            return "#3498DB"
        case .place:
            return "#27AE60"
        case .organization:
            return "#E74C3C"
        case .date:
            return "#9B59B6"
        case .time:
            return "#F39C12"
        case .money:
            return "#16A085"
        case .percentage:
            return "#E67E22"
        case .custom:
            return "#95A5A6"
        }
    }
}

// MARK: - Sample Data

#if DEBUG
extension NamedEntity {
    public static let samples: [NamedEntity] = [
        NamedEntity(
            text: "Sarah",
            type: .person,
            confidence: 0.95,
            startIndex: 0,
            endIndex: 5
        ),
        NamedEntity(
            text: "San Francisco",
            type: .place,
            confidence: 0.92,
            startIndex: 10,
            endIndex: 23
        ),
        NamedEntity(
            text: "Apple Inc.",
            type: .organization,
            confidence: 0.88,
            startIndex: 30,
            endIndex: 40
        ),
    ]

    public static var sample: NamedEntity {
        samples[0]
    }
}
#endif

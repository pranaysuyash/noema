import Foundation

/// Represents a tag/label that can be applied to notes
public struct Tag: Identifiable, Equatable, Codable, Sendable, Hashable {
    // MARK: - Properties

    public let id: UUID
    public var name: String
    public var colorHex: String
    public let createdAt: Date
    public var usageCount: Int

    // MARK: - Initialization

    public init(
        id: UUID = UUID(),
        name: String,
        colorHex: String = "#3498DB", // Default blue
        createdAt: Date = Date(),
        usageCount: Int = 0
    ) {
        self.id = id
        self.name = name
        self.colorHex = colorHex
        self.createdAt = createdAt
        self.usageCount = usageCount
    }

    // MARK: - Business Logic

    /// Increment usage count
    public mutating func incrementUsage() {
        usageCount += 1
    }

    /// Decrement usage count
    public mutating func decrementUsage() {
        usageCount = max(0, usageCount - 1)
    }

    /// Normalized name (lowercase, trimmed) for comparison
    public var normalizedName: String {
        name.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Check if tag is frequently used
    public var isFrequentlyUsed: Bool {
        usageCount >= 10
    }

    /// Display name with emoji if applicable
    public var displayName: String {
        let emoji = emojiForTagName(name)
        return emoji.isEmpty ? name : "\(emoji) \(name)"
    }

    // MARK: - Emoji Helpers

    private func emojiForTagName(_ name: String) -> String {
        let lowercased = name.lowercased()

        switch lowercased {
        case "work", "job", "office":
            return "💼"
        case "personal", "life":
            return "🌟"
        case "ideas", "brainstorm", "creative":
            return "💡"
        case "gratitude", "thankful":
            return "🙏"
        case "health", "fitness", "exercise":
            return "💪"
        case "family":
            return "👨‍👩‍👧‍👦"
        case "friends", "social":
            return "👥"
        case "travel", "trip":
            return "✈️"
        case "food", "cooking":
            return "🍽️"
        case "goals", "objectives":
            return "🎯"
        case "reading", "books":
            return "📚"
        case "learning", "education":
            return "🎓"
        case "meditation", "mindfulness":
            return "🧘"
        case "music":
            return "🎵"
        case "art", "creativity":
            return "🎨"
        case "coding", "programming":
            return "💻"
        default:
            return ""
        }
    }
}

// MARK: - Predefined Tags

extension Tag {
    /// Common predefined tags
    public static let predefined: [Tag] = [
        Tag(name: "work", colorHex: "#3498DB", usageCount: 0),
        Tag(name: "personal", colorHex: "#9B59B6", usageCount: 0),
        Tag(name: "ideas", colorHex: "#F39C12", usageCount: 0),
        Tag(name: "gratitude", colorHex: "#27AE60", usageCount: 0),
        Tag(name: "goals", colorHex: "#E74C3C", usageCount: 0),
        Tag(name: "health", colorHex: "#1ABC9C", usageCount: 0),
        Tag(name: "family", colorHex: "#E67E22", usageCount: 0),
        Tag(name: "friends", colorHex: "#16A085", usageCount: 0),
    ]
}

// MARK: - Sample Data

#if DEBUG
extension Tag {
    public static let work = Tag(name: "work", colorHex: "#3498DB", usageCount: 25)
    public static let personal = Tag(name: "personal", colorHex: "#9B59B6", usageCount: 18)
    public static let ideas = Tag(name: "ideas", colorHex: "#F39C12", usageCount: 12)
    public static let gratitude = Tag(name: "gratitude", colorHex: "#27AE60", usageCount: 30)

    public static let samples: [Tag] = [work, personal, ideas, gratitude]
    public static var sample: Tag { work }
}
#endif

import Foundation
import CoreData

// MARK: - Entity Model

/// Represents a named entity (person, place, organization, topic, etc.) extracted from notes
@objc(Entity)
public class Entity: NSManagedObject, Identifiable {

    // MARK: - Identity

    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged private var typeRaw: String

    public var type: EntityType {
        get {
            EntityType(rawValue: typeRaw) ?? .custom
        }
        set {
            typeRaw = newValue.rawValue
        }
    }

    // MARK: - Aliases

    @NSManaged private var aliasesRaw: String?  // Comma-separated
    @NSManaged public var canonicalName: String

    public var aliases: [String] {
        get {
            guard let raw = aliasesRaw else { return [] }
            return raw.split(separator: ",").map { String($0) }
        }
        set {
            aliasesRaw = newValue.joined(separator: ",")
        }
    }

    // MARK: - Metadata

    @NSManaged public var firstMentioned: Date
    @NSManaged public var lastMentioned: Date
    @NSManaged public var totalMentions: Int

    // MARK: - Emotional Association

    @NSManaged public var averageValence: Double
    @NSManaged public var averageArousal: Double
    @NSManaged public var averageEnergy: Double
    @NSManaged public var emotionalVariance: Double

    // MARK: - Importance & Centrality

    /// Graph centrality measure (0.0 - 1.0)
    @NSManaged public var importanceScore: Double

    /// Recency boost for recent mentions
    @NSManaged public var recencyScore: Double

    /// Frequency-based score
    @NSManaged public var frequencyScore: Double

    // MARK: - Custom Attributes

    /// Flexible JSON storage for type-specific attributes
    @NSManaged private var attributesJSON: String?

    public var attributes: [String: String] {
        get {
            guard let json = attributesJSON,
                  let data = json.data(using: .utf8),
                  let dict = try? JSONDecoder().decode([String: String].self, from: data) else {
                return [:]
            }
            return dict
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue),
                  let json = String(data: data, encoding: .utf8) else {
                attributesJSON = nil
                return
            }
            attributesJSON = json
        }
    }

    // MARK: - Relationships

    @NSManaged public var mentions: Set<EntityMention>
    @NSManaged public var relationships: Set<Relationship>

    // MARK: - User Control

    @NSManaged public var userNotes: String?
    @NSManaged public var isPrivate: Bool
    @NSManaged public var isFavorite: Bool
    @NSManaged public var color: String?

    // MARK: - Computed Properties

    public var displayName: String {
        canonicalName.isEmpty ? name : canonicalName
    }

    public var emoji: String {
        type.emoji
    }

    /// Days since last mention
    public var daysSinceLastMention: Int {
        Calendar.current.dateComponents([.day], from: lastMentioned, to: Date()).day ?? 0
    }

    /// Emotional impact score (-1 to 1)
    public var emotionalImpact: Double {
        // Weighted combination of valence and importance
        return (averageValence * 0.7) + ((importanceScore - 0.5) * 2 * 0.3)
    }

    // MARK: - Initialization

    public override func awakeFromInsert() {
        super.awakeFromInsert()

        id = UUID()
        name = ""
        type = .custom
        canonicalName = ""
        firstMentioned = Date()
        lastMentioned = Date()
        totalMentions = 0
        averageValence = 0
        averageArousal = 0
        averageEnergy = 0
        emotionalVariance = 0
        importanceScore = 0
        recencyScore = 0
        frequencyScore = 0
        isPrivate = false
        isFavorite = false
        mentions = Set()
        relationships = Set()
    }
}

// MARK: - EntityType Enum

public enum EntityType: String, Codable, CaseIterable {
    case person
    case place
    case organization
    case topic
    case project
    case goal
    case hobby
    case event
    case custom

    public var displayName: String {
        rawValue.capitalized
    }

    public var emoji: String {
        switch self {
        case .person: return "👤"
        case .place: return "📍"
        case .organization: return "🏢"
        case .topic: return "💡"
        case .project: return "📋"
        case .goal: return "🎯"
        case .hobby: return "🎨"
        case .event: return "📅"
        case .custom: return "⭐"
        }
    }
}

// MARK: - Extensions

extension Entity {

    /// Update emotional metrics based on mentions
    public func recalculateEmotionalMetrics() {
        guard !mentions.isEmpty else { return }

        let emotions = mentions.compactMap { $0.emotionalState }
        guard !emotions.isEmpty else { return }

        averageValence = emotions.reduce(0) { $0 + $1.valence } / Double(emotions.count)
        averageArousal = emotions.reduce(0) { $0 + $1.arousal } / Double(emotions.count)
        averageEnergy = emotions.reduce(0) { $0 + $1.energyLevel } / Double(emotions.count)

        // Calculate variance
        let valences = emotions.map { $0.valence }
        let mean = averageValence
        let squaredDiffs = valences.map { pow($0 - mean, 2) }
        emotionalVariance = squaredDiffs.reduce(0, +) / Double(valences.count)
    }

    /// Update importance score based on mentions and recency
    public func recalculateImportanceScore() {
        // Frequency component (normalized by max mentions, assumed 100)
        frequencyScore = min(1.0, Double(totalMentions) / 100.0)

        // Recency component (exponential decay, half-life = 30 days)
        let daysSince = Double(daysSinceLastMention)
        recencyScore = exp(-daysSince / 30.0)

        // Emotional impact component
        let emotionalImpactScore = (abs(averageValence) + emotionalVariance) / 2.0

        // Combined importance
        importanceScore = (frequencyScore * 0.4) +
                         (recencyScore * 0.4) +
                         (emotionalImpactScore * 0.2)
    }

    /// Add an alias to the entity
    public func addAlias(_ alias: String) {
        var currentAliases = aliases
        if !currentAliases.contains(alias) {
            currentAliases.append(alias)
            aliases = currentAliases
        }
    }

    /// Check if a string matches this entity (name or alias)
    public func matches(_ string: String) -> Bool {
        let normalized = string.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        return name.lowercased() == normalized ||
               canonicalName.lowercased() == normalized ||
               aliases.contains { $0.lowercased() == normalized }
    }
}

// MARK: - EntityMention Model

/// Represents a specific mention of an entity within a note
@objc(EntityMention)
public class EntityMention: NSManagedObject, Identifiable {

    // MARK: - Identity

    @NSManaged public var id: UUID

    // MARK: - References

    @NSManaged public var entity: Entity
    @NSManaged public var note: Note

    // MARK: - Position in Note

    @NSManaged public var position: Int
    @NSManaged public var contextSnippet: String

    // MARK: - Emotional Context

    @NSManaged public var emotionalState: EmotionalState?
    @NSManaged public var sentimentAtMention: Double  // -1 to 1

    // MARK: - Metadata

    @NSManaged public var timestamp: Date
    @NSManaged public var importance: Double

    // MARK: - Initialization

    public override func awakeFromInsert() {
        super.awakeFromInsert()

        id = UUID()
        position = 0
        contextSnippet = ""
        sentimentAtMention = 0
        timestamp = Date()
        importance = 0
    }
}

// MARK: - Relationship Model

/// Represents a connection between two entities
@objc(Relationship)
public class Relationship: NSManagedObject, Identifiable {

    // MARK: - Identity

    @NSManaged public var id: UUID

    // MARK: - Entities

    @NSManaged public var entity1: Entity
    @NSManaged public var entity2: Entity
    @NSManaged private var relationshipTypeRaw: String

    public var relationshipType: RelationshipType {
        get {
            RelationshipType(rawValue: relationshipTypeRaw) ?? .coOccurrence
        }
        set {
            relationshipTypeRaw = newValue.rawValue
        }
    }

    // MARK: - Strength & Frequency

    @NSManaged public var strength: Double
    @NSManaged public var coOccurrences: Int

    // MARK: - Emotional Tone

    @NSManaged public var averageEmotionalTone: Double
    @NSManaged public var emotionalVariance: Double

    // MARK: - Temporal

    @NSManaged public var firstCoOccurrence: Date
    @NSManaged public var lastCoOccurrence: Date

    // MARK: - User-Defined

    @NSManaged public var label: String?
    @NSManaged public var notes: String?

    // MARK: - Initialization

    public override func awakeFromInsert() {
        super.awakeFromInsert()

        id = UUID()
        relationshipType = .coOccurrence
        strength = 0
        coOccurrences = 0
        averageEmotionalTone = 0
        emotionalVariance = 0
        firstCoOccurrence = Date()
        lastCoOccurrence = Date()
    }
}

public enum RelationshipType: String, Codable {
    case coOccurrence          // Simply mentioned together
    case personToPerson        // Both are people
    case personToPlace         // Person associated with place
    case personToOrganization  // Employment, membership, etc.
    case personToTopic         // Interest, expertise
    case topicToTopic          // Related concepts
    case custom
}

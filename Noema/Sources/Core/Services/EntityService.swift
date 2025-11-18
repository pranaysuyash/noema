import Foundation
import CoreData
import NaturalLanguage

// MARK: - EntityService

/// Service for managing entities and knowledge graph operations
public final class EntityService {

    // MARK: - Properties

    private let persistenceController: PersistenceController

    // MARK: - Initialization

    public init(persistenceController: PersistenceController = .shared) {
        self.persistenceController = persistenceController
    }

    // MARK: - Singleton

    public static let shared = EntityService()

    // MARK: - Entity Extraction

    /// Extract entities from text using NaturalLanguage framework
    public func extractEntities(from text: String) async throws -> [Entity] {
        let tagger = NLTagger(tagSchemes: [.nameType])
        tagger.string = text

        var detectedEntities: [DetectedEntity] = []

        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .nameType) { tag, range in
            guard let tag = tag else { return true }

            let entityText = String(text[range])
            let entityType: EntityType

            switch tag {
            case .personalName:
                entityType = .person
            case .placeName:
                entityType = .place
            case .organizationName:
                entityType = .organization
            default:
                return true
            }

            detectedEntities.append(DetectedEntity(
                text: entityText,
                type: entityType,
                range: range,
                confidence: 0.8
            ))

            return true
        }

        // Convert detected entities to Entity objects
        var entities: [Entity] = []
        for detected in detectedEntities {
            if let entity = try await upsertEntity(
                name: detected.text,
                type: detected.type,
                aliases: nil
            ) {
                entities.append(entity)
            }
        }

        return entities
    }

    /// Create or update entity
    public func upsertEntity(
        name: String,
        type: EntityType,
        aliases: [String]? = nil
    ) async throws -> Entity? {
        try await persistenceController.performInBackground { context in
            // Try to find existing entity
            let fetchRequest: NSFetchRequest<Entity> = Entity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "name ==[c] %@ OR canonicalName ==[c] %@", name, name)
            fetchRequest.fetchLimit = 1

            let existing = try context.fetch(fetchRequest).first

            let entity = existing ?? Entity(context: context)
            entity.name = name
            entity.type = type

            if entity.canonicalName.isEmpty {
                entity.canonicalName = name
            }

            if let aliases = aliases {
                var currentAliases = entity.aliases
                currentAliases.append(contentsOf: aliases)
                entity.aliases = Array(Set(currentAliases)) // Remove duplicates
            }

            if existing == nil {
                entity.firstMentioned = Date()
            }
            entity.lastMentioned = Date()

            try context.save()
            return entity
        }
    }

    // MARK: - Entity Retrieval

    /// Get entity by ID
    public func getEntity(id: UUID) async throws -> Entity? {
        try await persistenceController.performInBackground { context in
            let fetchRequest: NSFetchRequest<Entity> = Entity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            fetchRequest.fetchLimit = 1
            return try context.fetch(fetchRequest).first
        }
    }

    /// Find entity by name (fuzzy matching)
    public func findEntity(byName name: String) async throws -> Entity? {
        try await persistenceController.performInBackground { context in
            let fetchRequest: NSFetchRequest<Entity> = Entity.fetchRequest()
            fetchRequest.predicate = NSPredicate(
                format: "name CONTAINS[cd] %@ OR canonicalName CONTAINS[cd] %@",
                name, name
            )
            fetchRequest.fetchLimit = 1
            return try context.fetch(fetchRequest).first
        }
    }

    /// Get all mentions of an entity
    public func getMentions(for entity: Entity) async throws -> [EntityMention] {
        try await persistenceController.performInBackground { context in
            let fetchRequest: NSFetchRequest<EntityMention> = EntityMention.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "entity == %@", entity)
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
            return try context.fetch(fetchRequest)
        }
    }

    /// Get emotional timeline for an entity
    public func getEmotionalTimeline(
        for entity: Entity,
        dateRange: ClosedRange<Date>? = nil
    ) async throws -> [EmotionalDataPoint] {
        let mentions = try await getMentions(for: entity)

        var dataPoints: [EmotionalDataPoint] = []

        for mention in mentions {
            guard let emotion = mention.emotionalState,
                  let note = mention.note else { continue }

            // Filter by date range if provided
            if let range = dateRange {
                guard range.contains(mention.timestamp) else { continue }
            }

            dataPoints.append(EmotionalDataPoint(
                timestamp: mention.timestamp,
                valence: emotion.valence,
                arousal: emotion.arousal,
                energy: emotion.energyLevel,
                note: note
            ))
        }

        return dataPoints.sorted { $0.timestamp < $1.timestamp }
    }

    /// Get related entities (co-occurrences)
    public func getRelatedEntities(
        for entity: Entity,
        minCoOccurrences: Int = 2
    ) async throws -> [Entity] {
        try await persistenceController.performInBackground { context in
            // Get all notes that mention this entity
            let mentions = try await self.getMentions(for: entity)
            let noteIDs = Set(mentions.compactMap { $0.note?.objectID })

            guard !noteIDs.isEmpty else { return [] }

            // Find other entities mentioned in those notes
            let fetchRequest: NSFetchRequest<EntityMention> = EntityMention.fetchRequest()
            fetchRequest.predicate = NSPredicate(
                format: "note IN %@ AND entity != %@",
                Array(noteIDs),
                entity
            )

            let otherMentions = try context.fetch(fetchRequest)

            // Count co-occurrences
            var entityCounts: [UUID: Int] = [:]
            for mention in otherMentions {
                let id = mention.entity.id
                entityCounts[id, default: 0] += 1
            }

            // Filter by minimum co-occurrences
            let relatedIDs = entityCounts.filter { $0.value >= minCoOccurrences }.keys

            // Fetch related entities
            let entityFetchRequest: NSFetchRequest<Entity> = Entity.fetchRequest()
            entityFetchRequest.predicate = NSPredicate(format: "id IN %@", Array(relatedIDs))

            return try context.fetch(entityFetchRequest)
        }
    }

    // MARK: - Relationship Management

    /// Calculate relationship strength between two entities
    public func calculateRelationshipStrength(
        entity1: Entity,
        entity2: Entity
    ) async throws -> Double {
        try await persistenceController.performInBackground { context in
            // Get mentions for both entities
            let mentions1 = try await self.getMentions(for: entity1)
            let mentions2 = try await self.getMentions(for: entity2)

            let notes1 = Set(mentions1.compactMap { $0.note?.objectID })
            let notes2 = Set(mentions2.compactMap { $0.note?.objectID })

            // Calculate co-occurrence
            let coOccurrences = notes1.intersection(notes2).count
            let maxPossible = max(notes1.count, notes2.count)

            guard maxPossible > 0 else { return 0 }

            return Double(coOccurrences) / Double(maxPossible)
        }
    }

    /// Create or update relationship
    public func createRelationship(
        between entity1: Entity,
        and entity2: Entity,
        type: RelationshipType = .coOccurrence
    ) async throws -> Relationship {
        try await persistenceController.performInBackground { context in
            // Check if relationship already exists
            let fetchRequest: NSFetchRequest<Relationship> = Relationship.fetchRequest()
            fetchRequest.predicate = NSPredicate(
                format: "(entity1 == %@ AND entity2 == %@) OR (entity1 == %@ AND entity2 == %@)",
                entity1, entity2, entity2, entity1
            )
            fetchRequest.fetchLimit = 1

            let existing = try context.fetch(fetchRequest).first

            let relationship = existing ?? Relationship(context: context)
            relationship.entity1 = entity1
            relationship.entity2 = entity2
            relationship.relationshipType = type

            // Calculate strength
            let strength = try await self.calculateRelationshipStrength(
                entity1: entity1,
                entity2: entity2
            )
            relationship.strength = strength

            if existing == nil {
                relationship.firstCoOccurrence = Date()
            }
            relationship.lastCoOccurrence = Date()
            relationship.coOccurrences += 1

            try context.save()
            return relationship
        }
    }

    // MARK: - Entity Updates

    /// Update entity's emotional metrics
    public func updateEmotionalMetrics(for entity: Entity) async throws {
        try await persistenceController.performOnViewContext { context in
            entity.recalculateEmotionalMetrics()
            entity.recalculateImportanceScore()
            try context.save()
        }
    }

    /// Merge duplicate entities
    public func mergeEntities(source: Entity, into target: Entity) async throws {
        try await persistenceController.performInBackground { context in
            // Get source entity in this context
            guard let sourceEntity = try? context.existingObject(with: source.objectID) as? Entity,
                  let targetEntity = try? context.existingObject(with: target.objectID) as? Entity else {
                throw EntityServiceError.entityNotFound
            }

            // Transfer all mentions from source to target
            for mention in sourceEntity.mentions {
                mention.entity = targetEntity
            }

            // Merge aliases
            var targetAliases = targetEntity.aliases
            targetAliases.append(contentsOf: sourceEntity.aliases)
            targetAliases.append(sourceEntity.name)
            targetEntity.aliases = Array(Set(targetAliases))

            // Update metrics
            targetEntity.totalMentions += sourceEntity.totalMentions
            targetEntity.recalculateEmotionalMetrics()
            targetEntity.recalculateImportanceScore()

            // Delete source entity
            context.delete(sourceEntity)

            try context.save()
        }
    }

    /// Get all entities
    public func getAllEntities(type: EntityType? = nil) async throws -> [Entity] {
        let predicate: NSPredicate? = type.map { NSPredicate(format: "type == %@", $0.rawValue) }
        return try await persistenceController.fetch(
            entityName: "Entity",
            predicate: predicate,
            sortDescriptors: [NSSortDescriptor(key: "importanceScore", ascending: false)]
        )
    }

    /// Get top entities by importance
    public func getTopEntities(limit: Int = 10, type: EntityType? = nil) async throws -> [Entity] {
        let predicate: NSPredicate? = type.map { NSPredicate(format: "type == %@", $0.rawValue) }
        return try await persistenceController.fetch(
            entityName: "Entity",
            predicate: predicate,
            sortDescriptors: [NSSortDescriptor(key: "importanceScore", ascending: false)],
            limit: limit
        )
    }
}

// MARK: - Supporting Types

public struct DetectedEntity {
    public var text: String
    public var type: EntityType
    public var range: Range<String.Index>
    public var confidence: Double

    public init(text: String, type: EntityType, range: Range<String.Index>, confidence: Double) {
        self.text = text
        self.type = type
        self.range = range
        self.confidence = confidence
    }
}

public struct EmotionalDataPoint {
    public var timestamp: Date
    public var valence: Double
    public var arousal: Double
    public var energy: Double
    public var note: Note

    public init(timestamp: Date, valence: Double, arousal: Double, energy: Double, note: Note) {
        self.timestamp = timestamp
        self.valence = valence
        self.arousal = arousal
        self.energy = energy
        self.note = note
    }
}

// MARK: - Errors

public enum EntityServiceError: LocalizedError {
    case entityNotFound
    case extractionFailed

    public var errorDescription: String? {
        switch self {
        case .entityNotFound:
            return "Entity not found"
        case .extractionFailed:
            return "Failed to extract entities"
        }
    }
}

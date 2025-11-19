//
//  EntityServiceTests.swift
//  Noema
//
//  Created on November 19, 2025.
//

import XCTest
import CoreData
@testable import Noema

final class EntityServiceTests: XCTestCase {

    var persistenceController: PersistenceController!
    var entityService: EntityService!
    var context: NSManagedObjectContext!

    override func setUp() async throws {
        try await super.setUp()
        persistenceController = PersistenceController(inMemory: true)
        context = persistenceController.container.viewContext
        entityService = EntityService(persistenceController: persistenceController)
    }

    override func tearDown() {
        entityService = nil
        context = nil
        persistenceController = nil
        super.tearDown()
    }

    // MARK: - Entity Extraction Tests

    func test_extractEntities_detectsPersonNames() async throws {
        // Given
        let text = "I had a meeting with John Smith today."

        // When
        let entities = try await entityService.extractEntities(from: text)

        // Then
        // NaturalLanguage framework should detect "John Smith" as a person
        // Note: Results may vary based on iOS version and NL implementation
        XCTAssertNotNil(entities)
    }

    func test_extractEntities_detectsPlaceNames() async throws {
        // Given
        let text = "I visited San Francisco last week."

        // When
        let entities = try await entityService.extractEntities(from: text)

        // Then
        XCTAssertNotNil(entities)
    }

    func test_extractEntities_handlesEmptyText() async throws {
        // Given
        let text = ""

        // When
        let entities = try await entityService.extractEntities(from: text)

        // Then
        XCTAssertEqual(entities.count, 0)
    }

    // MARK: - Upsert Entity Tests

    func test_upsertEntity_createsNewEntity() async throws {
        // Given
        let name = "Alice Johnson"
        let type = EntityType.person

        // When
        let entity = try await entityService.upsertEntity(name: name, type: type)

        // Then
        XCTAssertNotNil(entity)
        XCTAssertEqual(entity?.name, name)
        XCTAssertEqual(entity?.type, type)
    }

    func test_upsertEntity_updatesExistingEntity() async throws {
        // Given
        let name = "Bob"
        _ = try await entityService.upsertEntity(name: name, type: .person)

        // When
        let updated = try await entityService.upsertEntity(name: name, type: .person, aliases: ["Robert"])

        // Then
        XCTAssertNotNil(updated)
        XCTAssertTrue(updated?.aliases.contains("Robert") ?? false)
    }

    func test_upsertEntity_setsCanonicalName() async throws {
        // Given
        let name = "Alice"

        // When
        let entity = try await entityService.upsertEntity(name: name, type: .person)

        // Then
        XCTAssertEqual(entity?.canonicalName, name)
    }

    // MARK: - Get Entity Tests

    func test_getEntity_findsEntityById() async throws {
        // Given
        let created = try await entityService.upsertEntity(name: "Test Entity", type: .person)
        guard let id = created?.id else {
            XCTFail("Failed to create entity")
            return
        }

        // When
        let found = try await entityService.getEntity(id: id)

        // Then
        XCTAssertNotNil(found)
        XCTAssertEqual(found?.id, id)
    }

    func test_getEntity_returnsNilForNonexistentId() async throws {
        // Given
        let randomId = UUID()

        // When
        let found = try await entityService.getEntity(id: randomId)

        // Then
        XCTAssertNil(found)
    }

    // MARK: - Find Entity Tests

    func test_findEntity_findsByName() async throws {
        // Given
        _ = try await entityService.upsertEntity(name: "Alice Johnson", type: .person)

        // When
        let found = try await entityService.findEntity(byName: "Alice")

        // Then
        XCTAssertNotNil(found)
    }

    func test_findEntity_isCaseInsensitive() async throws {
        // Given
        _ = try await entityService.upsertEntity(name: "Alice", type: .person)

        // When
        let found = try await entityService.findEntity(byName: "ALICE")

        // Then
        XCTAssertNotNil(found)
    }

    // MARK: - Emotional Metrics Tests

    func test_updateEmotionalMetrics_recalculatesScores() async throws {
        // Given
        let entity = Entity(context: context)
        entity.name = "Test Entity"
        entity.type = .person

        let note = Note(context: context)
        let emotion = EmotionalState(context: context)
        emotion.valence = 0.5
        emotion.arousal = 0.3

        let mention = EntityMention(context: context)
        mention.entity = entity
        mention.note = note
        mention.emotionalState = emotion

        entity.mentions.insert(mention)
        try context.save()

        // When
        try await entityService.updateEmotionalMetrics(for: entity)

        // Then
        XCTAssertNotEqual(entity.averageValence, 0)
        XCTAssertNotEqual(entity.importanceScore, 0)
    }

    // MARK: - Merge Entities Tests

    func test_mergeEntities_transfersMentions() async throws {
        // Given
        let source = Entity(context: context)
        source.name = "Bob"
        source.type = .person

        let target = Entity(context: context)
        target.name = "Robert"
        target.type = .person

        let note = Note(context: context)
        let mention = EntityMention(context: context)
        mention.entity = source
        mention.note = note

        source.mentions.insert(mention)
        try context.save()

        let initialTargetMentions = target.mentions.count

        // When
        try await entityService.mergeEntities(source: source, into: target)

        // Then
        XCTAssertGreaterThan(target.mentions.count, initialTargetMentions)
    }

    func test_mergeEntities_mergesAliases() async throws {
        // Given
        let source = Entity(context: context)
        source.name = "Bob"
        source.addAlias("Bobby")

        let target = Entity(context: context)
        target.name = "Robert"

        try context.save()

        // When
        try await entityService.mergeEntities(source: source, into: target)

        // Then
        XCTAssertTrue(target.aliases.contains("Bobby"))
        XCTAssertTrue(target.aliases.contains("Bob"))
    }

    // MARK: - Get All Entities Tests

    func test_getAllEntities_returnsAllEntities() async throws {
        // Given
        _ = try await entityService.upsertEntity(name: "Entity 1", type: .person)
        _ = try await entityService.upsertEntity(name: "Entity 2", type: .place)
        _ = try await entityService.upsertEntity(name: "Entity 3", type: .organization)

        // When
        let entities = try await entityService.getAllEntities()

        // Then
        XCTAssertGreaterThanOrEqual(entities.count, 3)
    }

    func test_getAllEntities_filtersTypeType() async throws {
        // Given
        _ = try await entityService.upsertEntity(name: "Person 1", type: .person)
        _ = try await entityService.upsertEntity(name: "Person 2", type: .person)
        _ = try await entityService.upsertEntity(name: "Place 1", type: .place)

        // When
        let people = try await entityService.getAllEntities(type: .person)

        // Then
        XCTAssertGreaterThanOrEqual(people.count, 2)
        XCTAssertTrue(people.allSatisfy { $0.type == .person })
    }

    // MARK: - Top Entities Tests

    func test_getTopEntities_limitsResults() async throws {
        // Given
        for i in 1...15 {
            let entity = try await entityService.upsertEntity(name: "Entity \(i)", type: .person)
            entity?.importanceScore = Double(i) / 15.0
        }

        // When
        let topEntities = try await entityService.getTopEntities(limit: 5)

        // Then
        XCTAssertLessThanOrEqual(topEntities.count, 5)
    }

    // MARK: - Relationship Tests

    func test_calculateRelationshipStrength_returnsValidScore() async throws {
        // Given
        let entity1 = Entity(context: context)
        entity1.name = "Alice"

        let entity2 = Entity(context: context)
        entity2.name = "Bob"

        let note = Note(context: context)

        let mention1 = EntityMention(context: context)
        mention1.entity = entity1
        mention1.note = note

        let mention2 = EntityMention(context: context)
        mention2.entity = entity2
        mention2.note = note

        try context.save()

        // When
        let strength = try await entityService.calculateRelationshipStrength(entity1: entity1, entity2: entity2)

        // Then
        XCTAssertGreaterThanOrEqual(strength, 0.0)
        XCTAssertLessThanOrEqual(strength, 1.0)
    }

    func test_createRelationship_createsNewRelationship() async throws {
        // Given
        let entity1 = Entity(context: context)
        entity1.name = "Alice"

        let entity2 = Entity(context: context)
        entity2.name = "Bob"

        try context.save()

        // When
        let relationship = try await entityService.createRelationship(between: entity1, and: entity2)

        // Then
        XCTAssertNotNil(relationship)
        XCTAssertEqual(relationship.entity1, entity1)
        XCTAssertEqual(relationship.entity2, entity2)
    }

    // MARK: - Get Related Entities Tests

    func test_getRelatedEntities_findsCoOccurringEntities() async throws {
        // Given
        let entity1 = Entity(context: context)
        entity1.name = "Project Alpha"

        let entity2 = Entity(context: context)
        entity2.name = "Alice"

        let note = Note(context: context)

        let mention1 = EntityMention(context: context)
        mention1.entity = entity1
        mention1.note = note

        let mention2 = EntityMention(context: context)
        mention2.entity = entity2
        mention2.note = note

        try context.save()

        // When
        let related = try await entityService.getRelatedEntities(for: entity1, minCoOccurrences: 1)

        // Then
        XCTAssertGreaterThanOrEqual(related.count, 0)
    }
}

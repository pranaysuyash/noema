//
//  EntityTests.swift
//  Noema
//
//  Created on November 19, 2025.
//

import XCTest
import CoreData
@testable import Noema

final class EntityTests: XCTestCase {

    var persistenceController: PersistenceController!
    var context: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        persistenceController = PersistenceController(inMemory: true)
        context = persistenceController.container.viewContext
    }

    override func tearDown() {
        context = nil
        persistenceController = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func test_entityInitialization_setsDefaultValues() {
        // Given/When
        let entity = Entity(context: context)

        // Then
        XCTAssertNotNil(entity.id)
        XCTAssertEqual(entity.name, "")
        XCTAssertEqual(entity.type, .custom)
        XCTAssertEqual(entity.canonicalName, "")
        XCTAssertNotNil(entity.firstMentioned)
        XCTAssertNotNil(entity.lastMentioned)
        XCTAssertEqual(entity.totalMentions, 0)
        XCTAssertEqual(entity.importanceScore, 0)
        XCTAssertFalse(entity.isPrivate)
        XCTAssertFalse(entity.isFavorite)
    }

    // MARK: - Display Tests

    func test_displayName_usesCanonicalNameWhenSet() {
        // Given
        let entity = Entity(context: context)
        entity.name = "bob"
        entity.canonicalName = "Robert Smith"

        // When
        let displayName = entity.displayName

        // Then
        XCTAssertEqual(displayName, "Robert Smith")
    }

    func test_displayName_usesNameWhenCanonicalIsEmpty() {
        // Given
        let entity = Entity(context: context)
        entity.name = "Alice"
        entity.canonicalName = ""

        // When
        let displayName = entity.displayName

        // Then
        XCTAssertEqual(displayName, "Alice")
    }

    func test_emoji_returnsEmojiForType() {
        // Given
        let personEntity = Entity(context: context)
        personEntity.type = .person

        let placeEntity = Entity(context: context)
        placeEntity.type = .place

        // When
        let personEmoji = personEntity.emoji
        let placeEmoji = placeEntity.emoji

        // Then
        XCTAssertFalse(personEmoji.isEmpty)
        XCTAssertFalse(placeEmoji.isEmpty)
        XCTAssertNotEqual(personEmoji, placeEmoji)
    }

    // MARK: - Alias Tests

    func test_addAlias_addsNewAlias() {
        // Given
        let entity = Entity(context: context)
        entity.name = "Bob"

        // When
        entity.addAlias("Robert")
        entity.addAlias("Bobby")

        // Then
        XCTAssertEqual(entity.aliases.count, 2)
        XCTAssertTrue(entity.aliases.contains("Robert"))
        XCTAssertTrue(entity.aliases.contains("Bobby"))
    }

    func test_addAlias_doesNotAddDuplicates() {
        // Given
        let entity = Entity(context: context)
        entity.name = "Bob"

        // When
        entity.addAlias("Robert")
        entity.addAlias("Robert")

        // Then
        XCTAssertEqual(entity.aliases.count, 1)
    }

    // MARK: - Matching Tests

    func test_matches_returnsTrueForName() {
        // Given
        let entity = Entity(context: context)
        entity.name = "Alice"

        // When
        let result = entity.matches("Alice")

        // Then
        XCTAssertTrue(result)
    }

    func test_matches_returnsTrueForCanonicalName() {
        // Given
        let entity = Entity(context: context)
        entity.name = "Alice"
        entity.canonicalName = "Alice Johnson"

        // When
        let result = entity.matches("Alice Johnson")

        // Then
        XCTAssertTrue(result)
    }

    func test_matches_returnsTrueForAlias() {
        // Given
        let entity = Entity(context: context)
        entity.name = "Bob"
        entity.addAlias("Robert")

        // When
        let result = entity.matches("Robert")

        // Then
        XCTAssertTrue(result)
    }

    func test_matches_isCaseInsensitive() {
        // Given
        let entity = Entity(context: context)
        entity.name = "Alice"

        // When
        let result = entity.matches("ALICE")

        // Then
        XCTAssertTrue(result)
    }

    func test_matches_returnsFalseForNonMatch() {
        // Given
        let entity = Entity(context: context)
        entity.name = "Alice"

        // When
        let result = entity.matches("Bob")

        // Then
        XCTAssertFalse(result)
    }

    // MARK: - Emotional Metrics Tests

    func test_recalculateEmotionalMetrics_updatesValuesFromMentions() {
        // Given
        let entity = Entity(context: context)
        let note = Note(context: context)

        let emotion = EmotionalState(context: context)
        emotion.valence = 0.5
        emotion.arousal = 0.3
        emotion.energyLevel = 0.7

        let mention = EntityMention(context: context)
        mention.entity = entity
        mention.note = note
        mention.emotionalState = emotion

        entity.mentions.insert(mention)

        // When
        entity.recalculateEmotionalMetrics()

        // Then
        XCTAssertEqual(entity.averageValence, 0.5)
        XCTAssertEqual(entity.averageArousal, 0.3)
        XCTAssertEqual(entity.averageEnergy, 0.7)
    }

    // MARK: - Importance Score Tests

    func test_recalculateImportanceScore_updatesScore() {
        // Given
        let entity = Entity(context: context)
        entity.totalMentions = 50
        entity.lastMentioned = Date()

        // When
        entity.recalculateImportanceScore()

        // Then
        XCTAssertGreaterThan(entity.importanceScore, 0)
        XCTAssertLessThanOrEqual(entity.importanceScore, 1.0)
    }

    func test_recalculateImportanceScore_higherForRecentMentions() {
        // Given
        let recentEntity = Entity(context: context)
        recentEntity.totalMentions = 50
        recentEntity.lastMentioned = Date()

        let oldEntity = Entity(context: context)
        oldEntity.totalMentions = 50
        oldEntity.lastMentioned = Date().addingTimeInterval(-60 * 24 * 60 * 60) // 60 days ago

        // When
        recentEntity.recalculateImportanceScore()
        oldEntity.recalculateImportanceScore()

        // Then
        XCTAssertGreaterThan(recentEntity.importanceScore, oldEntity.importanceScore)
    }

    // MARK: - Emotional Impact Tests

    func test_emotionalImpact_calculatesCorrectly() {
        // Given
        let entity = Entity(context: context)
        entity.averageValence = 0.5
        entity.importanceScore = 0.8

        // When
        let impact = entity.emotionalImpact

        // Then
        XCTAssertGreaterThanOrEqual(impact, -1.0)
        XCTAssertLessThanOrEqual(impact, 1.0)
    }

    // MARK: - Days Since Last Mention Tests

    func test_daysSinceLastMention_calculatesCorrectly() {
        // Given
        let entity = Entity(context: context)
        entity.lastMentioned = Date().addingTimeInterval(-3 * 24 * 60 * 60) // 3 days ago

        // When
        let days = entity.daysSinceLastMention

        // Then
        XCTAssertEqual(days, 3)
    }

    // MARK: - Custom Attributes Tests

    func test_attributes_canBeSetAndRetrieved() {
        // Given
        let entity = Entity(context: context)
        let attributes: [String: String] = [
            "email": "alice@example.com",
            "phone": "555-1234"
        ]

        // When
        entity.attributes = attributes

        // Then
        XCTAssertEqual(entity.attributes["email"], "alice@example.com")
        XCTAssertEqual(entity.attributes["phone"], "555-1234")
    }

    // MARK: - EntityType Tests

    func test_entityType_allCasesHaveDisplayNames() {
        // Given/When/Then
        for type in EntityType.allCases {
            XCTAssertFalse(type.displayName.isEmpty)
        }
    }

    func test_entityType_allCasesHaveEmojis() {
        // Given/When/Then
        for type in EntityType.allCases {
            XCTAssertFalse(type.emoji.isEmpty)
        }
    }
}

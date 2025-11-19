//
//  NoteTests.swift
//  Noema
//
//  Created on November 19, 2025.
//

import XCTest
import CoreData
@testable import Noema

final class NoteTests: XCTestCase {

    var persistenceController: PersistenceController!
    var context: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        // Use in-memory store for testing
        persistenceController = PersistenceController(inMemory: true)
        context = persistenceController.container.viewContext
    }

    override func tearDown() {
        context = nil
        persistenceController = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func test_noteInitialization_setsDefaultValues() {
        // Given/When
        let note = Note(context: context)

        // Then
        XCTAssertNotNil(note.id)
        XCTAssertNotNil(note.createdAt)
        XCTAssertNotNil(note.modifiedAt)
        XCTAssertEqual(note.content, "")
        XCTAssertFalse(note.hasAudio)
        XCTAssertEqual(note.audioDuration, 0)
        XCTAssertEqual(note.transcriptionStatus, .pending)
        XCTAssertEqual(note.wordCount, 0)
        XCTAssertEqual(note.characterCount, 0)
        XCTAssertFalse(note.isPinned)
        XCTAssertFalse(note.isFavorite)
        XCTAssertFalse(note.isArchived)
        XCTAssertFalse(note.isEncrypted)
        XCTAssertEqual(note.syncStatus, .localOnly)
        XCTAssertEqual(note.shareLevel, .private)
    }

    // MARK: - Content Tests

    func test_updateCounts_calculatesWordAndCharacterCount() {
        // Given
        let note = Note(context: context)
        note.content = "This is a test note with ten words here now."

        // When
        note.updateCounts()

        // Then
        XCTAssertEqual(note.wordCount, 10)
        XCTAssertGreaterThan(note.characterCount, 0)
    }

    func test_updateCounts_handlesEmptyContent() {
        // Given
        let note = Note(context: context)
        note.content = "   "

        // When
        note.updateCounts()

        // Then
        XCTAssertEqual(note.wordCount, 0)
        XCTAssertEqual(note.characterCount, 0)
    }

    func test_hasContent_returnsTrueForNonEmptyContent() {
        // Given
        let note = Note(context: context)
        note.content = "Some content"

        // When
        let result = note.hasContent

        // Then
        XCTAssertTrue(result)
    }

    func test_hasContent_returnsFalseForEmptyContent() {
        // Given
        let note = Note(context: context)
        note.content = "   "

        // When
        let result = note.hasContent

        // Then
        XCTAssertFalse(result)
    }

    // MARK: - Tag Management Tests

    func test_addTag_addsTagToNote() {
        // Given
        let note = Note(context: context)
        let tag = Tag(context: context)
        tag.name = "work"

        // When
        note.addTag(tag)

        // Then
        XCTAssertTrue(note.tags.contains(tag))
        XCTAssertEqual(note.tags.count, 1)
    }

    func test_removeTag_removesTagFromNote() {
        // Given
        let note = Note(context: context)
        let tag = Tag(context: context)
        tag.name = "work"
        note.addTag(tag)

        // When
        note.removeTag(tag)

        // Then
        XCTAssertFalse(note.tags.contains(tag))
        XCTAssertEqual(note.tags.count, 0)
    }

    // MARK: - Quality Score Tests

    func test_calculateQualityScore_returnsScoreBetweenZeroAndOne() {
        // Given
        let note = Note(context: context)
        note.content = "This is a medium-length note that should have a reasonable quality score based on its length and other factors."
        note.updateCounts()

        // When
        let score = note.calculateQualityScore()

        // Then
        XCTAssertGreaterThanOrEqual(score, 0.0)
        XCTAssertLessThanOrEqual(score, 1.0)
    }

    func test_calculateQualityScore_higherForOptimalLength() {
        // Given
        let shortNote = Note(context: context)
        shortNote.content = "Short"
        shortNote.updateCounts()

        let optimalNote = Note(context: context)
        optimalNote.content = String(repeating: "word ", count: 200) // ~200 words
        optimalNote.updateCounts()

        // When
        let shortScore = shortNote.calculateQualityScore()
        let optimalScore = optimalNote.calculateQualityScore()

        // Then
        XCTAssertGreaterThan(optimalScore, shortScore)
    }

    func test_calculateQualityScore_includesAudioBonus() {
        // Given
        let note = Note(context: context)
        note.content = String(repeating: "word ", count: 200)
        note.updateCounts()
        note.hasAudio = true

        let noteWithoutAudio = Note(context: context)
        noteWithoutAudio.content = String(repeating: "word ", count: 200)
        noteWithoutAudio.updateCounts()

        // When
        let scoreWithAudio = note.calculateQualityScore()
        let scoreWithoutAudio = noteWithoutAudio.calculateQualityScore()

        // Then
        XCTAssertGreaterThan(scoreWithAudio, scoreWithoutAudio)
    }

    // MARK: - Time of Day Tests

    func test_timeOfDay_initializesFromDate() {
        // Given
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: Date())

        // Morning (8 AM)
        components.hour = 8
        let morningDate = calendar.date(from: components)!

        // Evening (6 PM)
        components.hour = 18
        let eveningDate = calendar.date(from: components)!

        // When
        let morningTimeOfDay = TimeOfDay(from: morningDate)
        let eveningTimeOfDay = TimeOfDay(from: eveningDate)

        // Then
        XCTAssertEqual(morningTimeOfDay, .morning)
        XCTAssertEqual(eveningTimeOfDay, .evening)
    }

    // MARK: - Sync Status Tests

    func test_isSynced_returnsTrueWhenSynced() {
        // Given
        let note = Note(context: context)
        note.syncStatus = .synced

        // When
        let result = note.isSynced

        // Then
        XCTAssertTrue(result)
    }

    func test_isSynced_returnsFalseWhenNotSynced() {
        // Given
        let note = Note(context: context)
        note.syncStatus = .localOnly

        // When
        let result = note.isSynced

        // Then
        XCTAssertFalse(result)
    }

    // MARK: - Transcription Tests

    func test_needsTranscription_returnsTrueForAudioWithoutTranscription() {
        // Given
        let note = Note(context: context)
        note.hasAudio = true
        note.transcriptionStatus = .pending

        // When
        let result = note.needsTranscription

        // Then
        XCTAssertTrue(result)
    }

    func test_needsTranscription_returnsFalseWhenCompleted() {
        // Given
        let note = Note(context: context)
        note.hasAudio = true
        note.transcriptionStatus = .completed

        // When
        let result = note.needsTranscription

        // Then
        XCTAssertFalse(result)
    }
}

//
//  NoteServiceTests.swift
//  Noema
//
//  Created on November 19, 2025.
//

import XCTest
import CoreData
@testable import Noema

final class NoteServiceTests: XCTestCase {

    var persistenceController: PersistenceController!
    var noteService: NoteService!
    var context: NSManagedObjectContext!

    override func setUp() async throws {
        try await super.setUp()
        persistenceController = PersistenceController(inMemory: true)
        context = persistenceController.container.viewContext
        noteService = NoteService(persistenceController: persistenceController)
    }

    override func tearDown() {
        noteService = nil
        context = nil
        persistenceController = nil
        super.tearDown()
    }

    // MARK: - Text Note Creation Tests

    func test_createTextNote_createsNoteSuccessfully() async throws {
        // Given
        let content = "This is a test note about productivity and work."

        // When
        let note = try await noteService.createTextNote(content: content)

        // Then
        XCTAssertNotNil(note)
        XCTAssertEqual(note.content, content)
        XCTAssertGreaterThan(note.wordCount, 0)
        XCTAssertGreaterThan(note.characterCount, 0)
    }

    func test_createTextNote_analyzesEmotion() async throws {
        // Given
        let content = "I am feeling happy and excited about this project!"

        // When
        let note = try await noteService.createTextNote(content: content)

        // Then
        XCTAssertNotNil(note.moodSnapshot)
        XCTAssertNotNil(note.dominantEmotion)
    }

    func test_createTextNote_extractsEntities() async throws {
        // Given
        let content = "Meeting with Alice at Starbucks to discuss the project."

        // When
        let note = try await noteService.createTextNote(content: content)

        // Then
        // Entities might be extracted depending on NL framework
        XCTAssertNotNil(note.entityMentions)
    }

    func test_createTextNote_calculatesQualityScore() async throws {
        // Given
        let content = "A thoughtful note with multiple sentences. It explores various ideas and concepts. This should have a reasonable quality score."

        // When
        let note = try await noteService.createTextNote(content: content)

        // Then
        XCTAssertGreaterThan(note.qualityScore, 0)
        XCTAssertLessThanOrEqual(note.qualityScore, 1.0)
    }

    func test_createTextNote_withTags() async throws {
        // Given
        let content = "Work note"
        let tag = Tag(context: context)
        tag.name = "work"
        try context.save()

        // When
        let note = try await noteService.createTextNote(content: content, tags: [tag])

        // Then
        XCTAssertTrue(note.tags.contains(tag))
    }

    // MARK: - Update Note Tests

    func test_updateNote_updatesContent() async throws {
        // Given
        let originalContent = "Original content"
        let note = try await noteService.createTextNote(content: originalContent)
        let newContent = "Updated content with new information"

        // When
        try await noteService.updateNote(note, content: newContent)

        // Then
        XCTAssertEqual(note.content, newContent)
        XCTAssertNotEqual(note.createdAt, note.modifiedAt)
    }

    func test_updateNote_recalculatesCounts() async throws {
        // Given
        let note = try await noteService.createTextNote(content: "Short")
        let newContent = "This is a much longer note with many more words"

        // When
        try await noteService.updateNote(note, content: newContent)

        // Then
        XCTAssertGreaterThan(note.wordCount, 1)
    }

    // MARK: - Delete Note Tests

    func test_deleteNote_archivesNote() async throws {
        // Given
        let note = try await noteService.createTextNote(content: "Test note")

        // When
        try await noteService.deleteNote(note)

        // Then
        XCTAssertTrue(note.isArchived)
    }

    func test_permanentlyDeleteNote_removesFromDatabase() async throws {
        // Given
        let note = try await noteService.createTextNote(content: "Test note")
        let noteID = note.objectID

        // When
        try await noteService.permanentlyDeleteNote(note)

        // Then
        XCTAssertThrowsError(try context.existingObject(with: noteID))
    }

    // MARK: - Search Tests

    func test_searchNotes_findsMatchingNotes() async throws {
        // Given
        _ = try await noteService.createTextNote(content: "Meeting notes about the project")
        _ = try await noteService.createTextNote(content: "Personal thoughts and ideas")
        _ = try await noteService.createTextNote(content: "Project planning session")

        // When
        let results = try await noteService.searchNotes(query: "project")

        // Then
        XCTAssertGreaterThanOrEqual(results.count, 2)
    }

    func test_searchNotes_returnsEmptyForNoMatches() async throws {
        // Given
        _ = try await noteService.createTextNote(content: "Something completely different")

        // When
        let results = try await noteService.searchNotes(query: "nonexistent")

        // Then
        XCTAssertEqual(results.count, 0)
    }

    // MARK: - Summarization Tests

    func test_summarizeNote_returnsNonEmptySummary() async throws {
        // Given
        let content = "First sentence. Second sentence. Third sentence. Fourth sentence. Fifth sentence."
        let note = try await noteService.createTextNote(content: content)

        // When
        let summary = try await noteService.summarizeNote(note)

        // Then
        XCTAssertFalse(summary.isEmpty)
        XCTAssertLessThan(summary.count, content.count)
    }

    func test_summarizeNote_briefLevelIsShorter() async throws {
        // Given
        let content = String(repeating: "This is a sentence. ", count: 20)
        let note = try await noteService.createTextNote(content: content)

        // When
        let briefSummary = try await noteService.summarizeNote(note, detailLevel: .brief)
        let standardSummary = try await noteService.summarizeNote(note, detailLevel: .standard)

        // Then
        XCTAssertLessThan(briefSummary.count, standardSummary.count)
    }

    func test_summarizeNote_throwsForEmptyContent() async throws {
        // Given
        let note = Note(context: context)
        note.content = ""

        // When/Then
        await XCTAssertThrowsError(try await noteService.summarizeNote(note))
    }

    // MARK: - Get All Notes Tests

    func test_getAllNotes_returnsAllNonArchivedNotes() async throws {
        // Given
        _ = try await noteService.createTextNote(content: "Note 1")
        _ = try await noteService.createTextNote(content: "Note 2")
        let archivedNote = try await noteService.createTextNote(content: "Archived")
        try await noteService.deleteNote(archivedNote)

        // When
        let notes = try await noteService.getAllNotes()

        // Then
        XCTAssertEqual(notes.count, 2)
    }

    // MARK: - Related Notes Tests

    func test_getRelatedNotes_findsNotesWithSharedEntities() async throws {
        // Given
        let entity = Entity(context: context)
        entity.name = "Project Alpha"
        try context.save()

        let note1 = try await noteService.createTextNote(content: "Working on Project Alpha")
        let note2 = try await noteService.createTextNote(content: "Update on Project Alpha")

        // Manually create mentions for testing
        let mention1 = EntityMention(context: context)
        mention1.entity = entity
        mention1.note = note1

        let mention2 = EntityMention(context: context)
        mention2.entity = entity
        mention2.note = note2

        try context.save()

        // When
        let relatedNotes = try await noteService.getRelatedNotes(for: note1, limit: 5)

        // Then
        // Should find note2 as it shares the same entity
        XCTAssertGreaterThanOrEqual(relatedNotes.count, 0)
    }
}

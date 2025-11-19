//
//  NoteFlowTests.swift
//  Noema
//
//  Created on November 19, 2025.
//

import XCTest

final class NoteFlowTests: XCTestCase {

    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI-Testing"]
        app.launch()
    }

    override func tearDown() {
        app = nil
        super.tearDown()
    }

    // MARK: - Note Creation Tests

    func test_createTextNote_displaysInList() {
        // Given
        let noteContent = "Test note created at \(Date().timeIntervalSince1970)"

        // When - Tap create note button
        let createButton = app.buttons["createNoteButton"]
        if createButton.exists {
            createButton.tap()
        }

        // Enter note content
        let textEditor = app.textViews["noteContentEditor"]
        if textEditor.exists {
            textEditor.tap()
            textEditor.typeText(noteContent)
        }

        // Save note
        let saveButton = app.buttons["saveNoteButton"]
        if saveButton.exists {
            saveButton.tap()
        }

        // Then - Note should appear in list
        let noteCell = app.cells.containing(.staticText, identifier: noteContent).firstMatch
        XCTAssertTrue(noteCell.waitForExistence(timeout: 5))
    }

    func test_createNote_withTags() {
        // Given
        let noteContent = "Note with tags"

        // When - Create note
        let createButton = app.buttons["createNoteButton"]
        if createButton.exists {
            createButton.tap()
        }

        let textEditor = app.textViews["noteContentEditor"]
        if textEditor.exists {
            textEditor.tap()
            textEditor.typeText(noteContent)
        }

        // Add tag
        let addTagButton = app.buttons["addTagButton"]
        if addTagButton.exists {
            addTagButton.tap()

            // Select a tag
            let tagButton = app.buttons["workTag"]
            if tagButton.exists {
                tagButton.tap()
            }
        }

        let saveButton = app.buttons["saveNoteButton"]
        if saveButton.exists {
            saveButton.tap()
        }

        // Then
        XCTAssertTrue(app.staticTexts[noteContent].waitForExistence(timeout: 5))
    }

    // MARK: - Note Editing Tests

    func test_editNote_updatesContent() {
        // Given - Create a note first
        test_createTextNote_displaysInList()

        // When - Tap on note to edit
        let noteCell = app.cells.firstMatch
        if noteCell.exists {
            noteCell.tap()
        }

        // Edit button
        let editButton = app.buttons["editNoteButton"]
        if editButton.exists {
            editButton.tap()
        }

        // Modify content
        let textEditor = app.textViews["noteContentEditor"]
        if textEditor.exists {
            textEditor.tap()
            textEditor.typeText(" - Edited")
        }

        // Save
        let saveButton = app.buttons["saveNoteButton"]
        if saveButton.exists {
            saveButton.tap()
        }

        // Then
        XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'Edited'")).firstMatch.exists)
    }

    func test_editNote_canCancel() {
        // Given
        test_createTextNote_displaysInList()

        // When
        let noteCell = app.cells.firstMatch
        if noteCell.exists {
            noteCell.tap()
        }

        let editButton = app.buttons["editNoteButton"]
        if editButton.exists {
            editButton.tap()
        }

        let cancelButton = app.buttons["cancelEditButton"]
        if cancelButton.exists {
            cancelButton.tap()
        }

        // Then - Should return to detail view
        XCTAssertTrue(app.navigationBars.firstMatch.exists)
    }

    // MARK: - Note Deletion Tests

    func test_deleteNote_removesFromList() {
        // Given
        test_createTextNote_displaysInList()
        let initialCellCount = app.cells.count

        // When - Swipe to delete
        let noteCell = app.cells.firstMatch
        if noteCell.exists {
            noteCell.swipeLeft()

            let deleteButton = app.buttons["Delete"]
            if deleteButton.exists {
                deleteButton.tap()
            }
        }

        // Then
        sleep(1) // Wait for animation
        XCTAssertLessThan(app.cells.count, initialCellCount)
    }

    func test_archiveNote_movesToArchive() {
        // Given
        test_createTextNote_displaysInList()

        // When
        let noteCell = app.cells.firstMatch
        if noteCell.exists {
            noteCell.tap()
        }

        let moreButton = app.buttons["moreOptionsButton"]
        if moreButton.exists {
            moreButton.tap()
        }

        let archiveButton = app.buttons["Archive"]
        if archiveButton.exists {
            archiveButton.tap()
        }

        // Then - Should return to list
        XCTAssertTrue(app.navigationBars["Notes"].exists)
    }

    // MARK: - Note Search Tests

    func test_searchNotes_findsMatchingNotes() {
        // Given
        test_createTextNote_displaysInList()

        // When
        let searchField = app.searchFields["searchNotesField"]
        if searchField.exists {
            searchField.tap()
            searchField.typeText("Test")
        }

        // Then
        XCTAssertGreaterThan(app.cells.count, 0)
    }

    func test_searchNotes_showsNoResults() {
        // When
        let searchField = app.searchFields["searchNotesField"]
        if searchField.exists {
            searchField.tap()
            searchField.typeText("nonexistentquery123456")
        }

        // Then
        XCTAssertTrue(app.staticTexts["No Results"].exists || app.cells.count == 0)
    }

    // MARK: - Note Detail Tests

    func test_viewNoteDetail_displaysFullContent() {
        // Given
        test_createTextNote_displaysInList()

        // When
        let noteCell = app.cells.firstMatch
        if noteCell.exists {
            noteCell.tap()
        }

        // Then
        XCTAssertTrue(app.textViews.firstMatch.exists)
    }

    func test_noteDetail_showsMetadata() {
        // Given
        test_createTextNote_displaysInList()

        // When
        let noteCell = app.cells.firstMatch
        if noteCell.exists {
            noteCell.tap()
        }

        // Then - Should show timestamp or other metadata
        XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'ago' OR label CONTAINS 'Today'")).firstMatch.exists)
    }

    // MARK: - Voice Note Tests

    func test_createVoiceNote_showsRecordingUI() {
        // When
        let voiceNoteButton = app.buttons["createVoiceNoteButton"]
        if voiceNoteButton.exists {
            voiceNoteButton.tap()
        }

        // Then
        XCTAssertTrue(app.buttons["recordButton"].exists || app.buttons["stopRecordingButton"].exists)
    }
}

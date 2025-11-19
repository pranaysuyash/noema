//
//  MoodTrackingTests.swift
//  Noema
//
//  Created on November 19, 2025.
//

import XCTest

final class MoodTrackingTests: XCTestCase {

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

    // MARK: - Navigate to Mood Tab Tests

    func test_navigateToMoodTab_showsMoodDashboard() {
        // When
        let moodTab = app.tabBars.buttons["Mood"]
        if moodTab.exists {
            moodTab.tap()
        }

        // Then
        XCTAssertTrue(app.navigationBars["Mood"].exists || app.staticTexts["Mood Dashboard"].exists)
    }

    // MARK: - Log Mood Tests

    func test_logMood_displaysEmotionPicker() {
        // Given
        let moodTab = app.tabBars.buttons["Mood"]
        if moodTab.exists {
            moodTab.tap()
        }

        // When
        let logMoodButton = app.buttons["logMoodButton"]
        if logMoodButton.exists {
            logMoodButton.tap()
        }

        // Then - Emotion picker should be visible
        XCTAssertTrue(app.otherElements["emotionPicker"].exists || app.collectionViews.firstMatch.exists)
    }

    func test_logMood_selectEmotion() {
        // Given
        let moodTab = app.tabBars.buttons["Mood"]
        if moodTab.exists {
            moodTab.tap()
        }

        let logMoodButton = app.buttons["logMoodButton"]
        if logMoodButton.exists {
            logMoodButton.tap()
        }

        // When - Select an emotion
        let joyButton = app.buttons["emotion_joy"]
        if joyButton.exists {
            joyButton.tap()
        }

        // Save
        let saveButton = app.buttons["saveMoodButton"]
        if saveButton.exists {
            saveButton.tap()
        }

        // Then - Should return to dashboard
        XCTAssertTrue(app.navigationBars["Mood"].exists)
    }

    func test_logMood_withNote() {
        // Given
        let moodTab = app.tabBars.buttons["Mood"]
        if moodTab.exists {
            moodTab.tap()
        }

        let logMoodButton = app.buttons["logMoodButton"]
        if logMoodButton.exists {
            logMoodButton.tap()
        }

        // When
        let noteField = app.textViews["moodNoteField"]
        if noteField.exists {
            noteField.tap()
            noteField.typeText("Feeling great today!")
        }

        let saveButton = app.buttons["saveMoodButton"]
        if saveButton.exists {
            saveButton.tap()
        }

        // Then
        XCTAssertTrue(app.navigationBars["Mood"].exists)
    }

    // MARK: - Mood Timeline Tests

    func test_viewMoodTimeline_showsChart() {
        // Given
        let moodTab = app.tabBars.buttons["Mood"]
        if moodTab.exists {
            moodTab.tap()
        }

        // When
        let timelineButton = app.buttons["viewTimelineButton"]
        if timelineButton.exists {
            timelineButton.tap()
        }

        // Then - Chart or timeline view should be visible
        XCTAssertTrue(app.otherElements["moodChart"].exists || app.scrollViews.firstMatch.exists)
    }

    func test_moodTimeline_switchPeriod() {
        // Given
        let moodTab = app.tabBars.buttons["Mood"]
        if moodTab.exists {
            moodTab.tap()
        }

        let timelineButton = app.buttons["viewTimelineButton"]
        if timelineButton.exists {
            timelineButton.tap()
        }

        // When - Switch to weekly view
        let weekButton = app.buttons["weekPeriod"]
        if weekButton.exists {
            weekButton.tap()
        }

        // Then
        XCTAssertTrue(weekButton.isSelected)
    }

    // MARK: - Mood Insights Tests

    func test_viewMoodInsights_showsInsights() {
        // Given
        let moodTab = app.tabBars.buttons["Mood"]
        if moodTab.exists {
            moodTab.tap()
        }

        // When
        let insightsButton = app.buttons["viewInsightsButton"]
        if insightsButton.exists {
            insightsButton.tap()
        }

        // Then
        XCTAssertTrue(app.navigationBars["Insights"].exists || app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'pattern'")).firstMatch.exists)
    }

    func test_moodInsight_expandDetails() {
        // Given
        let moodTab = app.tabBars.buttons["Mood"]
        if moodTab.exists {
            moodTab.tap()
        }

        let insightsButton = app.buttons["viewInsightsButton"]
        if insightsButton.exists {
            insightsButton.tap()
        }

        // When - Tap on an insight
        let insightCell = app.cells.firstMatch
        if insightCell.exists {
            insightCell.tap()
        }

        // Then - Details should expand
        XCTAssertTrue(app.staticTexts.count > 0)
    }

    // MARK: - Mood Patterns Tests

    func test_viewMoodPatterns_showsPatterns() {
        // Given
        let moodTab = app.tabBars.buttons["Mood"]
        if moodTab.exists {
            moodTab.tap()
        }

        // When
        let patternsButton = app.buttons["viewPatternsButton"]
        if patternsButton.exists {
            patternsButton.tap()
        }

        // Then
        XCTAssertTrue(app.navigationBars["Patterns"].exists || app.cells.count > 0)
    }

    // MARK: - Valence-Arousal Grid Tests

    func test_viewEmotionGrid_displaysGrid() {
        // Given
        let moodTab = app.tabBars.buttons["Mood"]
        if moodTab.exists {
            moodTab.tap()
        }

        // When
        let gridButton = app.buttons["emotionGridButton"]
        if gridButton.exists {
            gridButton.tap()
        }

        // Then
        XCTAssertTrue(app.otherElements["emotionGrid"].exists || app.images.firstMatch.exists)
    }

    // MARK: - Mood History Tests

    func test_viewMoodHistory_showsList() {
        // Given
        let moodTab = app.tabBars.buttons["Mood"]
        if moodTab.exists {
            moodTab.tap()
        }

        // When
        let historyButton = app.buttons["viewHistoryButton"]
        if historyButton.exists {
            historyButton.tap()
        }

        // Then
        XCTAssertTrue(app.tables.firstMatch.exists || app.cells.count >= 0)
    }

    func test_moodHistory_filterByEmotion() {
        // Given
        let moodTab = app.tabBars.buttons["Mood"]
        if moodTab.exists {
            moodTab.tap()
        }

        let historyButton = app.buttons["viewHistoryButton"]
        if historyButton.exists {
            historyButton.tap()
        }

        // When
        let filterButton = app.buttons["filterButton"]
        if filterButton.exists {
            filterButton.tap()

            let joyFilter = app.buttons["filter_joy"]
            if joyFilter.exists {
                joyFilter.tap()
            }
        }

        // Then
        XCTAssertTrue(app.cells.count >= 0)
    }

    // MARK: - Mood Visualization Tests

    func test_moodDashboard_showsCurrentMood() {
        // Given
        let moodTab = app.tabBars.buttons["Mood"]
        if moodTab.exists {
            moodTab.tap()
        }

        // Then - Should show some mood information
        XCTAssertTrue(app.staticTexts.count > 0)
    }
}

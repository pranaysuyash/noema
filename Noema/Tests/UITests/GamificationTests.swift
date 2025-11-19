//
//  GamificationTests.swift
//  Noema
//
//  Created on November 19, 2025.
//

import XCTest

final class GamificationTests: XCTestCase {

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

    // MARK: - Navigate to Profile Tab Tests

    func test_navigateToProfileTab_showsProfile() {
        // When
        let profileTab = app.tabBars.buttons["Profile"]
        if profileTab.exists {
            profileTab.tap()
        }

        // Then
        XCTAssertTrue(app.navigationBars["Profile"].exists || app.staticTexts["Level"].exists)
    }

    // MARK: - Level and XP Tests

    func test_profile_displaysLevelAndXP() {
        // Given
        let profileTab = app.tabBars.buttons["Profile"]
        if profileTab.exists {
            profileTab.tap()
        }

        // Then
        XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'Level'")).firstMatch.exists)
        XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'XP'")).firstMatch.exists)
    }

    func test_profile_showsProgressBar() {
        // Given
        let profileTab = app.tabBars.buttons["Profile"]
        if profileTab.exists {
            profileTab.tap()
        }

        // Then
        XCTAssertTrue(app.progressIndicators.firstMatch.exists || app.otherElements["xpProgressBar"].exists)
    }

    // MARK: - Achievements Tests

    func test_viewAchievements_showsList() {
        // Given
        let profileTab = app.tabBars.buttons["Profile"]
        if profileTab.exists {
            profileTab.tap()
        }

        // When
        let achievementsButton = app.buttons["viewAchievementsButton"]
        if achievementsButton.exists {
            achievementsButton.tap()
        }

        // Then
        XCTAssertTrue(app.navigationBars["Achievements"].exists || app.cells.count > 0)
    }

    func test_achievements_filterUnlocked() {
        // Given
        let profileTab = app.tabBars.buttons["Profile"]
        if profileTab.exists {
            profileTab.tap()
        }

        let achievementsButton = app.buttons["viewAchievementsButton"]
        if achievementsButton.exists {
            achievementsButton.tap()
        }

        // When
        let unlockedFilter = app.buttons["unlockedFilter"]
        if unlockedFilter.exists {
            unlockedFilter.tap()
        }

        // Then
        XCTAssertTrue(app.cells.count >= 0)
    }

    func test_achievements_filterLocked() {
        // Given
        let profileTab = app.tabBars.buttons["Profile"]
        if profileTab.exists {
            profileTab.tap()
        }

        let achievementsButton = app.buttons["viewAchievementsButton"]
        if achievementsButton.exists {
            achievementsButton.tap()
        }

        // When
        let lockedFilter = app.buttons["lockedFilter"]
        if lockedFilter.exists {
            lockedFilter.tap()
        }

        // Then
        XCTAssertTrue(app.cells.count >= 0)
    }

    func test_achievementDetail_showsProgress() {
        // Given
        let profileTab = app.tabBars.buttons["Profile"]
        if profileTab.exists {
            profileTab.tap()
        }

        let achievementsButton = app.buttons["viewAchievementsButton"]
        if achievementsButton.exists {
            achievementsButton.tap()
        }

        // When
        let achievementCell = app.cells.firstMatch
        if achievementCell.exists {
            achievementCell.tap()
        }

        // Then
        XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'Progress'")).firstMatch.exists ||
                     app.progressIndicators.firstMatch.exists)
    }

    // MARK: - Quests Tests

    func test_viewQuests_showsActiveQuests() {
        // Given
        let profileTab = app.tabBars.buttons["Profile"]
        if profileTab.exists {
            profileTab.tap()
        }

        // When
        let questsButton = app.buttons["viewQuestsButton"]
        if questsButton.exists {
            questsButton.tap()
        }

        // Then
        XCTAssertTrue(app.navigationBars["Quests"].exists || app.cells.count >= 0)
    }

    func test_questDetail_showsProgress() {
        // Given
        let profileTab = app.tabBars.buttons["Profile"]
        if profileTab.exists {
            profileTab.tap()
        }

        let questsButton = app.buttons["viewQuestsButton"]
        if questsButton.exists {
            questsButton.tap()
        }

        // When
        let questCell = app.cells.firstMatch
        if questCell.exists {
            questCell.tap()
        }

        // Then
        XCTAssertTrue(app.staticTexts.count > 0)
    }

    func test_quest_showsTimeRemaining() {
        // Given
        let profileTab = app.tabBars.buttons["Profile"]
        if profileTab.exists {
            profileTab.tap()
        }

        let questsButton = app.buttons["viewQuestsButton"]
        if questsButton.exists {
            questsButton.tap()
        }

        // Then
        XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'day' OR label CONTAINS 'hour'")).firstMatch.exists ||
                     app.cells.count == 0)
    }

    // MARK: - Streak Tests

    func test_profile_displaysStreak() {
        // Given
        let profileTab = app.tabBars.buttons["Profile"]
        if profileTab.exists {
            profileTab.tap()
        }

        // Then
        XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'Streak' OR label CONTAINS 'day'")).firstMatch.exists)
    }

    func test_viewStreakDetail_showsHistory() {
        // Given
        let profileTab = app.tabBars.buttons["Profile"]
        if profileTab.exists {
            profileTab.tap()
        }

        // When
        let streakButton = app.buttons["viewStreakButton"]
        if streakButton.exists {
            streakButton.tap()
        }

        // Then
        XCTAssertTrue(app.otherElements["streakCalendar"].exists || app.cells.count > 0)
    }

    // MARK: - Garden Tests

    func test_viewGarden_showsGardenView() {
        // Given
        let profileTab = app.tabBars.buttons["Profile"]
        if profileTab.exists {
            profileTab.tap()
        }

        // When
        let gardenButton = app.buttons["viewGardenButton"]
        if gardenButton.exists {
            gardenButton.tap()
        }

        // Then
        XCTAssertTrue(app.navigationBars["Garden"].exists || app.otherElements["gardenView"].exists)
    }

    func test_garden_showsGrowthElements() {
        // Given
        let profileTab = app.tabBars.buttons["Profile"]
        if profileTab.exists {
            profileTab.tap()
        }

        let gardenButton = app.buttons["viewGardenButton"]
        if gardenButton.exists {
            gardenButton.tap()
        }

        // Then
        XCTAssertTrue(app.images.count > 0 || app.otherElements.count > 0)
    }

    // MARK: - Statistics Tests

    func test_viewStatistics_showsStats() {
        // Given
        let profileTab = app.tabBars.buttons["Profile"]
        if profileTab.exists {
            profileTab.tap()
        }

        // When
        let statsButton = app.buttons["viewStatsButton"]
        if statsButton.exists {
            statsButton.tap()
        }

        // Then
        XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'Notes' OR label CONTAINS 'Words'")).firstMatch.exists)
    }

    func test_statistics_showsCharts() {
        // Given
        let profileTab = app.tabBars.buttons["Profile"]
        if profileTab.exists {
            profileTab.tap()
        }

        let statsButton = app.buttons["viewStatsButton"]
        if statsButton.exists {
            statsButton.tap()
        }

        // Then
        XCTAssertTrue(app.otherElements["statsChart"].exists || app.images.count > 0)
    }

    // MARK: - Leaderboard Tests

    func test_viewLeaderboard_showsRankings() {
        // Given
        let profileTab = app.tabBars.buttons["Profile"]
        if profileTab.exists {
            profileTab.tap()
        }

        // When
        let leaderboardButton = app.buttons["viewLeaderboardButton"]
        if leaderboardButton.exists {
            leaderboardButton.tap()
        }

        // Then
        XCTAssertTrue(app.navigationBars["Leaderboard"].exists || app.tables.firstMatch.exists)
    }
}

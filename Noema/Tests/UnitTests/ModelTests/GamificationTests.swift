//
//  GamificationTests.swift
//  Noema
//
//  Created on November 19, 2025.
//

import XCTest
import CoreData
@testable import Noema

final class GamificationTests: XCTestCase {

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

    // MARK: - Achievement Tests

    func test_achievementInitialization_setsDefaultValues() {
        // Given/When
        let achievement = Achievement(context: context)

        // Then
        XCTAssertNotNil(achievement.id)
        XCTAssertEqual(achievement.title, "")
        XCTAssertEqual(achievement.achievementDescription, "")
        XCTAssertEqual(achievement.progress, 0)
        XCTAssertFalse(achievement.isCompleted)
        XCTAssertNil(achievement.unlockedAt)
        XCTAssertEqual(achievement.xpReward, 0)
    }

    func test_achievement_progressPercentage() {
        // Given
        let achievement = Achievement(context: context)
        achievement.requiredValue = 100
        achievement.progress = 50

        // When
        let percentage = achievement.progressPercentage

        // Then
        XCTAssertEqual(percentage, 0.5)
    }

    func test_achievement_progressPercentageCappedAtOne() {
        // Given
        let achievement = Achievement(context: context)
        achievement.requiredValue = 100
        achievement.progress = 150

        // When
        let percentage = achievement.progressPercentage

        // Then
        XCTAssertEqual(percentage, 1.0)
    }

    func test_achievement_updateProgressUnlocksWhenComplete() {
        // Given
        let achievement = Achievement(context: context)
        achievement.requiredValue = 100

        // When
        let unlocked = achievement.updateProgress(to: 100)

        // Then
        XCTAssertTrue(unlocked)
        XCTAssertTrue(achievement.isCompleted)
        XCTAssertNotNil(achievement.unlockedAt)
    }

    func test_achievement_updateProgressDoesNotUnlockWhenIncomplete() {
        // Given
        let achievement = Achievement(context: context)
        achievement.requiredValue = 100

        // When
        let unlocked = achievement.updateProgress(to: 50)

        // Then
        XCTAssertFalse(unlocked)
        XCTAssertFalse(achievement.isCompleted)
    }

    func test_achievement_displayProgress() {
        // Given
        let achievement = Achievement(context: context)
        achievement.requiredValue = 100
        achievement.progress = 45

        // When
        let display = achievement.displayProgress

        // Then
        XCTAssertEqual(display, "45 / 100")
    }

    // MARK: - Quest Tests

    func test_questInitialization_setsDefaultValues() {
        // Given/When
        let quest = Quest(context: context)

        // Then
        XCTAssertNotNil(quest.id)
        XCTAssertEqual(quest.title, "")
        XCTAssertEqual(quest.targetValue, 0)
        XCTAssertEqual(quest.currentProgress, 0)
        XCTAssertFalse(quest.isCompleted)
        XCTAssertFalse(quest.isPersonalized)
    }

    func test_quest_progressPercentage() {
        // Given
        let quest = Quest(context: context)
        quest.targetValue = 10
        quest.currentProgress = 7

        // When
        let percentage = quest.progressPercentage

        // Then
        XCTAssertEqual(percentage, 0.7, accuracy: 0.01)
    }

    func test_quest_isActiveWhenInDateRange() {
        // Given
        let quest = Quest(context: context)
        quest.startDate = Date().addingTimeInterval(-60 * 60) // 1 hour ago
        quest.endDate = Date().addingTimeInterval(60 * 60) // 1 hour from now

        // When
        let isActive = quest.isActive

        // Then
        XCTAssertTrue(isActive)
    }

    func test_quest_isNotActiveWhenBeforeStartDate() {
        // Given
        let quest = Quest(context: context)
        quest.startDate = Date().addingTimeInterval(60 * 60) // 1 hour from now
        quest.endDate = Date().addingTimeInterval(2 * 60 * 60) // 2 hours from now

        // When
        let isActive = quest.isActive

        // Then
        XCTAssertFalse(isActive)
    }

    func test_quest_isNotActiveWhenAfterEndDate() {
        // Given
        let quest = Quest(context: context)
        quest.startDate = Date().addingTimeInterval(-2 * 60 * 60) // 2 hours ago
        quest.endDate = Date().addingTimeInterval(-60 * 60) // 1 hour ago

        // When
        let isActive = quest.isActive

        // Then
        XCTAssertFalse(isActive)
    }

    func test_quest_isExpiredWhenPastEndDateAndNotCompleted() {
        // Given
        let quest = Quest(context: context)
        quest.endDate = Date().addingTimeInterval(-60 * 60) // 1 hour ago
        quest.isCompleted = false

        // When
        let isExpired = quest.isExpired

        // Then
        XCTAssertTrue(isExpired)
    }

    func test_quest_isNotExpiredWhenCompleted() {
        // Given
        let quest = Quest(context: context)
        quest.endDate = Date().addingTimeInterval(-60 * 60) // 1 hour ago
        quest.isCompleted = true

        // When
        let isExpired = quest.isExpired

        // Then
        XCTAssertFalse(isExpired)
    }

    func test_quest_completeMarksAsCompleted() {
        // Given
        let quest = Quest(context: context)

        // When
        quest.complete()

        // Then
        XCTAssertTrue(quest.isCompleted)
        XCTAssertNotNil(quest.completedAt)
    }

    // MARK: - UserProfile Tests

    func test_userProfileInitialization_setsDefaultValues() {
        // Given/When
        let profile = UserProfile(context: context)

        // Then
        XCTAssertNotNil(profile.id)
        XCTAssertEqual(profile.level, 1)
        XCTAssertEqual(profile.totalXP, 0)
        XCTAssertEqual(profile.currentStreak, 0)
        XCTAssertEqual(profile.longestStreak, 0)
        XCTAssertEqual(profile.streakFreezes, 2)
        XCTAssertEqual(profile.totalNotes, 0)
        XCTAssertFalse(profile.isPro)
    }

    func test_userProfile_awardXPIncreasesTotalXP() {
        // Given
        let profile = UserProfile(context: context)
        let initialXP = profile.totalXP

        // When
        _ = profile.awardXP(50)

        // Then
        XCTAssertEqual(profile.totalXP, initialXP + 50)
    }

    func test_userProfile_awardXPCausesLevelUp() {
        // Given
        let profile = UserProfile(context: context)
        profile.level = 1
        profile.totalXP = 0

        // When
        let leveledUp = profile.awardXP(200) // Should level up

        // Then
        XCTAssertTrue(leveledUp)
        XCTAssertEqual(profile.level, 2)
    }

    func test_userProfile_levelUpAwardsStreakFreezeEveryFiveLevels() {
        // Given
        let profile = UserProfile(context: context)
        profile.level = 4
        let initialFreezes = profile.streakFreezes

        // When
        profile.levelUp()

        // Then
        XCTAssertEqual(profile.level, 5)
        XCTAssertEqual(profile.streakFreezes, initialFreezes + 1)
    }

    func test_userProfile_updateStreakIncrementsForConsecutiveDays() {
        // Given
        let profile = UserProfile(context: context)
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        profile.lastNoteDate = yesterday
        profile.currentStreak = 5

        // When
        profile.updateStreak()

        // Then
        XCTAssertEqual(profile.currentStreak, 6)
    }

    func test_userProfile_updateStreakResetForFirstNote() {
        // Given
        let profile = UserProfile(context: context)
        profile.lastNoteDate = nil

        // When
        profile.updateStreak()

        // Then
        XCTAssertEqual(profile.currentStreak, 1)
    }

    func test_userProfile_isPro_trueForProSubscription() {
        // Given
        let profile = UserProfile(context: context)
        profile.subscriptionTier = .pro

        // When
        let isPro = profile.isPro

        // Then
        XCTAssertTrue(isPro)
    }

    func test_userProfile_isPro_trueForLifetimeMember() {
        // Given
        let profile = UserProfile(context: context)
        profile.subscriptionTier = .free
        profile.isLifetimeMember = true

        // When
        let isPro = profile.isPro

        // Then
        XCTAssertTrue(isPro)
    }

    func test_userProfile_xpProgress() {
        // Given
        let profile = UserProfile(context: context)
        profile.level = 1
        profile.totalXP = 50 // Halfway to level 2 (assuming 100 XP needed)

        // When
        let progress = profile.xpProgress

        // Then
        XCTAssertGreaterThanOrEqual(progress, 0.0)
        XCTAssertLessThanOrEqual(progress, 1.0)
    }

    func test_userProfile_useStreakFreeze() {
        // Given
        let profile = UserProfile(context: context)
        profile.streakFreezes = 2

        // When
        let success = profile.useStreakFreeze()

        // Then
        XCTAssertTrue(success)
        XCTAssertEqual(profile.streakFreezes, 1)
    }

    func test_userProfile_useStreakFreezeFailsWhenNoneAvailable() {
        // Given
        let profile = UserProfile(context: context)
        profile.streakFreezes = 0

        // When
        let success = profile.useStreakFreeze()

        // Then
        XCTAssertFalse(success)
    }

    // MARK: - Garden State Tests

    func test_gardenState_canBeSetAndRetrieved() {
        // Given
        let profile = UserProfile(context: context)
        var garden = GardenState()
        garden.trees.append(GardenTree(type: "Oak", growthLevel: 5, position: CGPoint(x: 10, y: 20)))

        // When
        profile.gardenState = garden

        // Then
        let retrieved = profile.gardenState
        XCTAssertEqual(retrieved.trees.count, 1)
        XCTAssertEqual(retrieved.trees.first?.type, "Oak")
        XCTAssertEqual(retrieved.trees.first?.growthLevel, 5)
    }
}

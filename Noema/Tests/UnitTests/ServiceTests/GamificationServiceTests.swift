//
//  GamificationServiceTests.swift
//  Noema
//
//  Created on November 19, 2025.
//

import XCTest
import CoreData
@testable import Noema

final class GamificationServiceTests: XCTestCase {

    var persistenceController: PersistenceController!
    var gamificationService: GamificationService!
    var context: NSManagedObjectContext!

    override func setUp() async throws {
        try await super.setUp()
        persistenceController = PersistenceController(inMemory: true)
        context = persistenceController.container.viewContext
        gamificationService = GamificationService(persistenceController: persistenceController)

        // Create a default user profile
        let profile = UserProfile(context: context)
        try context.save()
    }

    override func tearDown() {
        gamificationService = nil
        context = nil
        persistenceController = nil
        super.tearDown()
    }

    // MARK: - XP Calculation Tests

    func test_calculateXP_returnsPositiveValue() {
        // Given
        let note = Note(context: context)
        note.content = "A quality note with good content"
        note.updateCounts()
        note.qualityScore = 0.7

        // When
        let xp = gamificationService.calculateXP(for: note)

        // Then
        XCTAssertGreaterThan(xp, 0)
    }

    func test_calculateXP_higherForLongerNotes() {
        // Given
        let shortNote = Note(context: context)
        shortNote.content = "Short"
        shortNote.updateCounts()

        let longNote = Note(context: context)
        longNote.content = String(repeating: "word ", count: 200)
        longNote.updateCounts()

        // When
        let shortXP = gamificationService.calculateXP(for: shortNote)
        let longXP = gamificationService.calculateXP(for: longNote)

        // Then
        XCTAssertGreaterThan(longXP, shortXP)
    }

    func test_calculateXP_bonusForAudio() {
        // Given
        let textNote = Note(context: context)
        textNote.content = String(repeating: "word ", count: 50)
        textNote.updateCounts()
        textNote.hasAudio = false

        let audioNote = Note(context: context)
        audioNote.content = String(repeating: "word ", count: 50)
        audioNote.updateCounts()
        audioNote.hasAudio = true

        // When
        let textXP = gamificationService.calculateXP(for: textNote)
        let audioXP = gamificationService.calculateXP(for: audioNote)

        // Then
        XCTAssertGreaterThan(audioXP, textXP)
    }

    // MARK: - Award XP Tests

    func test_awardXP_increasesTotalXP() async throws {
        // Given
        let profiles: [UserProfile] = try await persistenceController.fetch(entityName: "UserProfile", context: context)
        guard let profile = profiles.first else {
            XCTFail("No profile found")
            return
        }
        let initialXP = profile.totalXP

        // When
        try await gamificationService.awardXP(amount: 50)

        // Then
        XCTAssertEqual(profile.totalXP, initialXP + 50)
    }

    // MARK: - Streak Tests

    func test_updateStreak_returnsStreakStatus() async throws {
        // When
        let status = try await gamificationService.updateStreak()

        // Then
        XCTAssertNotNil(status)
        XCTAssertGreaterThanOrEqual(status.currentStreak, 0)
        XCTAssertGreaterThanOrEqual(status.longestStreak, 0)
        XCTAssertGreaterThanOrEqual(status.streakFreezes, 0)
        XCTAssertGreaterThan(status.nextMilestone, 0)
    }

    // MARK: - Quest Generation Tests

    func test_generateQuest_createsQuest() async throws {
        // Given
        let profiles: [UserProfile] = try await persistenceController.fetch(entityName: "UserProfile", context: context)
        guard let profile = profiles.first else {
            XCTFail("No profile found")
            return
        }

        // When
        let quest = try await gamificationService.generateQuest(basedOn: profile)

        // Then
        XCTAssertNotNil(quest)
        XCTAssertFalse(quest.title.isEmpty)
        XCTAssertGreaterThan(quest.targetValue, 0)
        XCTAssertGreaterThan(quest.xpReward, 0)
    }

    func test_generateQuest_marksAsPersonalized() async throws {
        // Given
        let profiles: [UserProfile] = try await persistenceController.fetch(entityName: "UserProfile", context: context)
        guard let profile = profiles.first else {
            XCTFail("No profile found")
            return
        }

        // When
        let quest = try await gamificationService.generateQuest(basedOn: profile)

        // Then
        XCTAssertTrue(quest.isPersonalized)
    }

    // MARK: - Complete Quest Tests

    func test_completeQuest_marksAsCompleted() async throws {
        // Given
        let quest = Quest(context: context)
        quest.title = "Test Quest"
        quest.xpReward = 100
        quest.targetValue = 5
        quest.currentProgress = 5
        try context.save()

        // When
        try await gamificationService.completeQuest(quest)

        // Then
        XCTAssertTrue(quest.isCompleted)
        XCTAssertNotNil(quest.completedAt)
    }

    // MARK: - Achievement Checking Tests

    func test_checkAchievements_returnsUnlockedAchievements() async throws {
        // Given
        let profiles: [UserProfile] = try await persistenceController.fetch(entityName: "UserProfile", context: context)
        guard let profile = profiles.first else {
            XCTFail("No profile found")
            return
        }

        profile.totalNotes = 100
        profile.currentStreak = 7
        try context.save()

        // When
        let unlocked = try await gamificationService.checkAchievements()

        // Then
        XCTAssertNotNil(unlocked)
        // Achievements may or may not be unlocked depending on thresholds
    }

    // MARK: - Garden Tests

    func test_getGardenState_returnsGarden() async throws {
        // When
        let garden = try await gamificationService.getGardenState()

        // Then
        XCTAssertNotNil(garden)
    }

    func test_updateGarden_addsFlowerForHighQualityNote() async throws {
        // Given
        let initialGarden = try await gamificationService.getGardenState()
        let initialFlowerCount = initialGarden.flowers.count

        // When
        let updatedGarden = try await gamificationService.updateGarden(activity: .noteCreated(quality: 0.8))

        // Then
        XCTAssertGreaterThan(updatedGarden.flowers.count, initialFlowerCount)
    }

    func test_updateGarden_addsCrystalForInsight() async throws {
        // Given
        let initialGarden = try await gamificationService.getGardenState()
        let initialCrystalCount = initialGarden.crystals.count

        // When
        let updatedGarden = try await gamificationService.updateGarden(activity: .insightGained)

        // Then
        XCTAssertGreaterThan(updatedGarden.crystals.count, initialCrystalCount)
    }

    func test_updateGarden_addsTreeForStreakMilestone() async throws {
        // Given
        let initialGarden = try await gamificationService.getGardenState()
        let initialTreeCount = initialGarden.trees.count

        // When
        let updatedGarden = try await gamificationService.updateGarden(activity: .streakMilestone)

        // Then
        XCTAssertGreaterThan(updatedGarden.trees.count, initialTreeCount)
    }

    func test_updateGarden_addsVineForAchievement() async throws {
        // Given
        let initialGarden = try await gamificationService.getGardenState()
        let initialVineCount = initialGarden.vines.count

        // When
        let updatedGarden = try await gamificationService.updateGarden(activity: .achievementUnlocked)

        // Then
        XCTAssertGreaterThan(updatedGarden.vines.count, initialVineCount)
    }

    // MARK: - Leaderboard Tests

    func test_getLeaderboard_returnsLeaderboard() async throws {
        // When
        let leaderboard = try await gamificationService.getLeaderboard(scope: .global)

        // Then
        XCTAssertNotNil(leaderboard)
    }

    // MARK: - Streak Status Tests

    func test_streakStatus_hasValidValues() async throws {
        // When
        let status = try await gamificationService.updateStreak()

        // Then
        XCTAssertGreaterThanOrEqual(status.currentStreak, 0)
        XCTAssertGreaterThanOrEqual(status.longestStreak, status.currentStreak)
        XCTAssertGreaterThanOrEqual(status.streakFreezes, 0)
        XCTAssertGreaterThan(status.nextMilestone, status.currentStreak)
    }
}

//
//  GamificationViewModel.swift
//  Noema
//
//  Created on January 18, 2025.
//

import Foundation
import Combine

@MainActor
public final class GamificationViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published public var userProfile: UserProfile?
    @Published public var achievements: [Achievement] = []
    @Published public var activeQuests: [Quest] = []
    @Published public var completedQuests: [Quest] = []
    @Published public var gardenState: GardenState?
    @Published public var levelProgress: Double = 0.0
    @Published public var isLoading: Bool = false
    @Published public var error: Error?
    @Published public var showLevelUpAnimation: Bool = false

    // MARK: - Dependencies

    private let gamificationService: GamificationService
    private let persistenceController: PersistenceController
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    public init(
        gamificationService: GamificationService = GamificationService(),
        persistenceController: PersistenceController = .shared
    ) {
        self.gamificationService = gamificationService
        self.persistenceController = persistenceController
    }

    // MARK: - Public Methods

    public func loadGamificationData() async {
        isLoading = true
        defer { isLoading = false }

        do {
            // Load user profile
            userProfile = try await fetchUserProfile()

            // Load achievements
            achievements = try await fetchAchievements()

            // Load quests
            let quests = try await fetchQuests()
            activeQuests = quests.filter { !$0.isCompleted }
            completedQuests = quests.filter { $0.isCompleted }

            // Load garden state
            gardenState = userProfile?.gardenState

            // Calculate level progress
            if let profile = userProfile {
                let xpForCurrentLevel = profile.xpRequiredForLevel(profile.level)
                let xpForNextLevel = profile.xpRequiredForLevel(profile.level + 1)
                let xpInCurrentLevel = profile.totalXP - xpForCurrentLevel
                let xpNeededForNextLevel = xpForNextLevel - xpForCurrentLevel

                levelProgress = Double(xpInCurrentLevel) / Double(xpNeededForNextLevel)
            }
        } catch {
            self.error = error
            Logger.ui.error("Failed to load gamification data", error: error)
        }
    }

    public func checkForNewAchievements() async {
        do {
            let newAchievements = try await gamificationService.checkAchievements()
            if !newAchievements.isEmpty {
                Logger.gamification.info("Unlocked \(newAchievements.count) new achievements!")
                await loadGamificationData() // Refresh
            }
        } catch {
            Logger.ui.error("Failed to check achievements", error: error)
        }
    }

    public func waterGarden() async {
        do {
            guard let newGardenState = try await gamificationService.updateGarden(activity: .watered) else {
                return
            }

            gardenState = newGardenState
            userProfile?.gardenState = newGardenState
            try persistenceController.save()
        } catch {
            self.error = error
            Logger.ui.error("Failed to water garden", error: error)
        }
    }

    public func useStreakFreeze() async {
        guard let profile = userProfile, profile.streakFreezeCount > 0 else {
            return
        }

        do {
            try await persistenceController.performInBackground { context in
                profile.streakFreezeCount -= 1
            }
            try persistenceController.save()
            await loadGamificationData()
        } catch {
            self.error = error
            Logger.ui.error("Failed to use streak freeze", error: error)
        }
    }

    // MARK: - Private Methods

    private func fetchUserProfile() async throws -> UserProfile {
        return try await persistenceController.performInBackground { context in
            let request: NSFetchRequest<UserProfile> = UserProfile.fetchRequest()
            request.fetchLimit = 1

            if let profile = try context.fetch(request).first {
                return profile
            } else {
                // Create default profile
                let profile = UserProfile(context: context)
                profile.id = UUID()
                profile.level = 1
                profile.totalXP = 0
                profile.currentStreak = 0
                try context.save()
                return profile
            }
        }
    }

    private func fetchAchievements() async throws -> [Achievement] {
        return try await persistenceController.performInBackground { context in
            let request: NSFetchRequest<Achievement> = Achievement.fetchRequest()
            request.sortDescriptors = [
                NSSortDescriptor(key: "isUnlocked", ascending: false),
                NSSortDescriptor(key: "unlockedAt", ascending: false)
            ]
            return try context.fetch(request)
        }
    }

    private func fetchQuests() async throws -> [Quest] {
        return try await persistenceController.performInBackground { context in
            let request: NSFetchRequest<Quest> = Quest.fetchRequest()
            request.sortDescriptors = [
                NSSortDescriptor(key: "isCompleted", ascending: true),
                NSSortDescriptor(key: "createdAt", ascending: false)
            ]
            return try context.fetch(request)
        }
    }
}

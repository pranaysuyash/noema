import Foundation
import CoreData

// MARK: - GamificationService

/// Service for managing achievements, quests, and user progression
public final class GamificationService {

    // MARK: - Properties

    private let persistenceController: PersistenceController

    // MARK: - Initialization

    public init(persistenceController: PersistenceController = .shared) {
        self.persistenceController = persistenceController
    }

    // MARK: - Singleton

    public static let shared = GamificationService()

    // MARK: - XP & Leveling

    /// Calculate XP for a note
    public func calculateXP(for note: Note) -> Int {
        var xp = 0

        // Base XP for creating a note
        xp += 5

        // Quality bonus
        xp += Int(note.qualityScore * 10)

        // Length bonus (up to 10 XP)
        let lengthBonus = min(10, note.wordCount / 50)
        xp += lengthBonus

        // Audio bonus
        if note.hasAudio {
            xp += 5
        }

        // Entity bonus (1 XP per entity, up to 10)
        xp += min(10, note.entityMentions.count)

        // Emotion depth bonus
        if note.emotionIntensity > 0.7 {
            xp += 5
        }

        return xp
    }

    /// Award XP to user
    public func awardXP(amount: Int) async throws {
        try await persistenceController.performOnViewContext { context in
            let profiles: [UserProfile] = try self.persistenceController.fetch(
                entityName: "UserProfile",
                limit: 1,
                context: context
            )

            guard let profile = profiles.first else {
                throw GamificationServiceError.profileNotFound
            }

            let leveledUp = profile.awardXP(amount)

            if leveledUp {
                // Unlock level milestone achievements
                try await self.checkLevelAchievements(profile: profile)
            }

            try context.save()
        }
    }

    // MARK: - Achievements

    /// Check for unlocked achievements
    public func checkAchievements() async throws -> [Achievement] {
        try await persistenceController.performInBackground { context in
            let profiles: [UserProfile] = try self.persistenceController.fetch(
                entityName: "UserProfile",
                limit: 1,
                context: context
            )

            guard let profile = profiles.first else {
                throw GamificationServiceError.profileNotFound
            }

            var newlyUnlocked: [Achievement] = []

            // Check streak achievements
            newlyUnlocked.append(contentsOf: try await self.checkStreakAchievements(profile: profile, context: context))

            // Check note count achievements
            newlyUnlocked.append(contentsOf: try await self.checkNoteCountAchievements(profile: profile, context: context))

            // Check emotional intelligence achievements
            newlyUnlocked.append(contentsOf: try await self.checkEmotionalAchievements(profile: profile, context: context))

            try context.save()
            return newlyUnlocked
        }
    }

    private func checkStreakAchievements(profile: UserProfile, context: NSManagedObjectContext) async throws -> [Achievement] {
        var unlocked: [Achievement] = []

        let streakMilestones: [(days: Int, type: AchievementType)] = [
            (7, .streak7Days),
            (30, .streak30Days),
            (100, .streak100Days),
            (365, .streak365Days)
        ]

        for (days, type) in streakMilestones {
            if profile.currentStreak >= days {
                if let achievement = try await getOrCreateAchievement(type: type, context: context) {
                    if achievement.updateProgress(to: profile.currentStreak) {
                        unlocked.append(achievement)
                    }
                }
            }
        }

        return unlocked
    }

    private func checkNoteCountAchievements(profile: UserProfile, context: NSManagedObjectContext) async throws -> [Achievement] {
        var unlocked: [Achievement] = []

        let noteMilestones: [(count: Int, type: AchievementType)] = [
            (100, .notes100),
            (500, .notes500),
            (1000, .notes1000)
        ]

        for (count, type) in noteMilestones {
            if profile.totalNotes >= count {
                if let achievement = try await getOrCreateAchievement(type: type, context: context) {
                    if achievement.updateProgress(to: profile.totalNotes) {
                        unlocked.append(achievement)
                    }
                }
            }
        }

        return unlocked
    }

    private func checkEmotionalAchievements(profile: UserProfile, context: NSManagedObjectContext) async throws -> [Achievement] {
        // Placeholder for emotional intelligence achievements
        return []
    }

    private func checkLevelAchievements(profile: UserProfile) async throws {
        // Award achievements for level milestones
        if profile.level % 10 == 0 {
            // Every 10 levels, award special achievement
        }
    }

    private func getOrCreateAchievement(type: AchievementType, context: NSManagedObjectContext) async throws -> Achievement? {
        let fetchRequest: NSFetchRequest<Achievement> = Achievement.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "typeRaw == %@", type.rawValue)
        fetchRequest.fetchLimit = 1

        if let existing = try context.fetch(fetchRequest).first {
            return existing
        }

        // Create new achievement
        let achievement = Achievement(context: context)
        achievement.type = type
        achievement.title = type.rawValue.capitalized
        achievement.achievementDescription = "Achievement description"
        achievement.requiredValue = getRequiredValue(for: type)
        achievement.xpReward = getXPReward(for: type)

        return achievement
    }

    private func getRequiredValue(for type: AchievementType) -> Int {
        switch type {
        case .streak7Days: return 7
        case .streak30Days: return 30
        case .streak100Days: return 100
        case .streak365Days: return 365
        case .notes100: return 100
        case .notes500: return 500
        case .notes1000: return 1000
        default: return 1
        }
    }

    private func getXPReward(for type: AchievementType) -> Int {
        switch type {
        case .streak7Days: return 50
        case .streak30Days: return 200
        case .streak100Days: return 1000
        case .streak365Days: return 5000
        case .notes100: return 100
        case .notes500: return 500
        case .notes1000: return 2000
        default: return 10
        }
    }

    // MARK: - Streak Management

    /// Update streak status
    public func updateStreak() async throws -> StreakStatus {
        try await persistenceController.performOnViewContext { context in
            let profiles: [UserProfile] = try self.persistenceController.fetch(
                entityName: "UserProfile",
                limit: 1,
                context: context
            )

            guard let profile = profiles.first else {
                throw GamificationServiceError.profileNotFound
            }

            profile.updateStreak()
            try context.save()

            return StreakStatus(
                currentStreak: profile.currentStreak,
                longestStreak: profile.longestStreak,
                streakFreezes: profile.streakFreezes,
                nextMilestone: getNextStreakMilestone(current: profile.currentStreak)
            )
        }
    }

    private func getNextStreakMilestone(current: Int) -> Int {
        let milestones = [7, 30, 100, 365]
        return milestones.first { $0 > current } ?? (current + 100)
    }

    // MARK: - Quests

    /// Generate personalized quest
    public func generateQuest(basedOn profile: UserProfile) async throws -> Quest {
        try await persistenceController.performInBackground { context in
            // Get profile in this context
            guard let contextProfile = try? context.existingObject(with: profile.objectID) as? UserProfile else {
                throw GamificationServiceError.profileNotFound
            }

            let quest = Quest(context: context)
            quest.title = "Weekly Reflection Challenge"
            quest.questDescription = "Create 7 notes this week"
            quest.type = .consistency
            quest.duration = .weekly
            quest.targetValue = 7
            quest.xpReward = 100
            quest.isPersonalized = true
            quest.userProfile = contextProfile

            try context.save()
            return quest
        }
    }

    /// Mark quest as completed
    public func completeQuest(_ quest: Quest) async throws {
        try await persistenceController.performOnViewContext { context in
            quest.complete()

            // Award XP
            try await self.awardXP(amount: quest.xpReward)

            try context.save()
        }
    }

    // MARK: - Garden

    /// Get garden state
    public func getGardenState() async throws -> GardenState {
        try await persistenceController.performInBackground { context in
            let profiles: [UserProfile] = try self.persistenceController.fetch(
                entityName: "UserProfile",
                limit: 1,
                context: context
            )

            guard let profile = profiles.first else {
                throw GamificationServiceError.profileNotFound
            }

            return profile.gardenState
        }
    }

    /// Update garden based on activity
    public func updateGarden(activity: GardenActivity) async throws -> GardenState {
        try await persistenceController.performOnViewContext { context in
            let profiles: [UserProfile] = try self.persistenceController.fetch(
                entityName: "UserProfile",
                limit: 1,
                context: context
            )

            guard let profile = profiles.first else {
                throw GamificationServiceError.profileNotFound
            }

            var garden = profile.gardenState

            switch activity {
            case .noteCreated(let quality):
                // Add flower based on quality
                if quality > 0.7 {
                    let flower = GardenFlower(
                        type: "Rose",
                        bloomLevel: Int(quality * 10),
                        position: CGPoint(x: Double.random(in: 0...100), y: Double.random(in: 0...100))
                    )
                    garden.flowers.append(flower)
                }
            case .insightGained:
                // Add crystal
                let crystal = GardenCrystal(
                    type: "Insight",
                    brightness: 1.0,
                    position: CGPoint(x: Double.random(in: 0...100), y: Double.random(in: 0...100))
                )
                garden.crystals.append(crystal)
            case .streakMilestone:
                // Add tree
                let tree = GardenTree(
                    type: "Oak",
                    growthLevel: profile.currentStreak / 10,
                    position: CGPoint(x: Double.random(in: 0...100), y: Double.random(in: 0...100))
                )
                garden.trees.append(tree)
            case .achievementUnlocked:
                // Add vine
                let vine = GardenVine(
                    type: "Ivy",
                    length: 5,
                    position: CGPoint(x: Double.random(in: 0...100), y: Double.random(in: 0...100))
                )
                garden.vines.append(vine)
            }

            profile.gardenState = garden
            try context.save()

            return garden
        }
    }

    // MARK: - Leaderboard (Optional Feature)

    /// Get leaderboard
    public func getLeaderboard(scope: LeaderboardScope) async throws -> [LeaderboardEntry] {
        // Placeholder - would implement server-side leaderboard
        return []
    }
}

// MARK: - Supporting Types

public struct StreakStatus {
    public var currentStreak: Int
    public var longestStreak: Int
    public var streakFreezes: Int
    public var nextMilestone: Int

    public init(currentStreak: Int, longestStreak: Int, streakFreezes: Int, nextMilestone: Int) {
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.streakFreezes = streakFreezes
        self.nextMilestone = nextMilestone
    }
}

public enum GardenActivity {
    case noteCreated(quality: Double)
    case insightGained
    case streakMilestone
    case achievementUnlocked
}

public enum LeaderboardScope {
    case global
    case friends
    case local
}

public struct LeaderboardEntry {
    public var rank: Int
    public var username: String
    public var level: Int
    public var totalXP: Int

    public init(rank: Int, username: String, level: Int, totalXP: Int) {
        self.rank = rank
        self.username = username
        self.level = level
        self.totalXP = totalXP
    }
}

// MARK: - Errors

public enum GamificationServiceError: LocalizedError {
    case profileNotFound
    case achievementNotFound

    public var errorDescription: String? {
        switch self {
        case .profileNotFound:
            return "User profile not found"
        case .achievementNotFound:
            return "Achievement not found"
        }
    }
}

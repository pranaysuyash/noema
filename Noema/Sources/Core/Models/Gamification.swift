import Foundation
import CoreData

// MARK: - Achievement Model

/// Represents unlockable achievements and badges
@objc(Achievement)
public class Achievement: NSManagedObject, Identifiable {

    // MARK: - Identity

    @NSManaged public var id: UUID

    // MARK: - Definition

    @NSManaged private var typeRaw: String
    @NSManaged private var categoryRaw: String
    @NSManaged public var title: String
    @NSManaged public var achievementDescription: String

    public var type: AchievementType {
        get {
            AchievementType(rawValue: typeRaw) ?? .notes100
        }
        set {
            typeRaw = newValue.rawValue
        }
    }

    public var category: AchievementCategory {
        get {
            AchievementCategory(rawValue: categoryRaw) ?? .consistency
        }
        set {
            categoryRaw = newValue.rawValue
        }
    }

    // MARK: - Visuals

    @NSManaged public var iconName: String
    @NSManaged public var badgeImageURL: String?
    @NSManaged public var color: String

    // MARK: - Unlock Criteria

    @NSManaged public var requiredValue: Int
    @NSManaged public var progress: Int
    @NSManaged public var isCompleted: Bool
    @NSManaged public var unlockedAt: Date?

    // MARK: - Rewards

    @NSManaged public var xpReward: Int

    // MARK: - Rarity

    @NSManaged private var rarityRaw: String

    public var rarity: AchievementRarity {
        get {
            AchievementRarity(rawValue: rarityRaw) ?? .common
        }
        set {
            rarityRaw = newValue.rawValue
        }
    }

    // MARK: - Relationships

    @NSManaged public var userProfile: UserProfile?

    // MARK: - Computed Properties

    public var progressPercentage: Double {
        guard requiredValue > 0 else { return 0 }
        return min(1.0, Double(progress) / Double(requiredValue))
    }

    public var isUnlocked: Bool {
        isCompleted
    }

    public var displayProgress: String {
        "\(progress) / \(requiredValue)"
    }

    // MARK: - Initialization

    public override func awakeFromInsert() {
        super.awakeFromInsert()

        id = UUID()
        type = .notes100
        category = .consistency
        title = ""
        achievementDescription = ""
        iconName = "star.fill"
        color = "#FFD700"
        requiredValue = 0
        progress = 0
        isCompleted = false
        xpReward = 0
        rarity = .common
    }

    // MARK: - Methods

    /// Update progress and check if achievement is unlocked
    @discardableResult
    public func updateProgress(to value: Int) -> Bool {
        progress = value
        if progress >= requiredValue && !isCompleted {
            unlock()
            return true
        }
        return false
    }

    /// Unlock the achievement
    public func unlock() {
        isCompleted = true
        unlockedAt = Date()
    }
}

// MARK: - Achievement Enums

public enum AchievementType: String, Codable {
    // Consistency
    case streak7Days = "week_warrior"
    case streak30Days = "monthly_master"
    case streak100Days = "centurion"
    case streak365Days = "year_champion"

    // Volume
    case notes100 = "hundred_thoughts"
    case notes500 = "wisdom_collector"
    case notes1000 = "knowledge_architect"

    // Emotional Intelligence
    case patternRecognized = "pattern_recognizer"
    case breakthrough = "breakthrough_moment"
    case emotionalBalance = "balance_seeker"
    case selfAwareness = "mirror_master"

    // Relationships
    case connectionCurator = "connection_curator"
    case socialScientist = "social_scientist"

    // Quality
    case deepThinker = "deep_thinker"
    case insightfulWriter = "insightful_writer"

    // Exploration
    case knowledgeExplorer = "knowledge_explorer"
    case graphNavigator = "graph_navigator"
}

public enum AchievementCategory: String, Codable {
    case consistency
    case emotionalIntelligence
    case relationships
    case wellness
    case insights
}

public enum AchievementRarity: String, Codable {
    case common
    case uncommon
    case rare
    case epic
    case legendary

    public var color: String {
        switch self {
        case .common: return "#9E9E9E"      // Gray
        case .uncommon: return "#4CAF50"    // Green
        case .rare: return "#2196F3"        // Blue
        case .epic: return "#9C27B0"        // Purple
        case .legendary: return "#FF9800"   // Orange/Gold
        }
    }
}

// MARK: - Quest Model

/// AI-generated or system-defined challenges for user engagement
@objc(Quest)
public class Quest: NSManagedObject, Identifiable {

    // MARK: - Identity

    @NSManaged public var id: UUID

    // MARK: - Definition

    @NSManaged public var title: String
    @NSManaged public var questDescription: String
    @NSManaged private var typeRaw: String

    public var type: QuestType {
        get {
            QuestType(rawValue: typeRaw) ?? .consistency
        }
        set {
            typeRaw = newValue.rawValue
        }
    }

    // MARK: - Timing

    @NSManaged public var startDate: Date
    @NSManaged public var endDate: Date
    @NSManaged private var durationRaw: String

    public var duration: QuestDuration {
        get {
            QuestDuration(rawValue: durationRaw) ?? .weekly
        }
        set {
            durationRaw = newValue.rawValue
        }
    }

    // MARK: - Progress

    @NSManaged public var targetValue: Int
    @NSManaged public var currentProgress: Int
    @NSManaged public var isCompleted: Bool
    @NSManaged public var completedAt: Date?

    // MARK: - Rewards

    @NSManaged public var xpReward: Int
    @NSManaged public var badgeReward: Achievement?

    // MARK: - Personalization

    @NSManaged public var isPersonalized: Bool
    @NSManaged public var personalizationReason: String?

    // MARK: - Relationships

    @NSManaged public var userProfile: UserProfile?

    // MARK: - Computed Properties

    public var progressPercentage: Double {
        guard targetValue > 0 else { return 0 }
        return min(1.0, Double(currentProgress) / Double(targetValue))
    }

    public var isActive: Bool {
        let now = Date()
        return now >= startDate && now <= endDate && !isCompleted
    }

    public var isExpired: Bool {
        Date() > endDate && !isCompleted
    }

    public var daysRemaining: Int {
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: Date(), to: endDate).day ?? 0
        return max(0, days)
    }

    // MARK: - Initialization

    public override func awakeFromInsert() {
        super.awakeFromInsert()

        id = UUID()
        title = ""
        questDescription = ""
        type = .consistency
        startDate = Date()
        endDate = Date().addingTimeInterval(7 * 24 * 60 * 60)  // 7 days
        duration = .weekly
        targetValue = 0
        currentProgress = 0
        isCompleted = false
        xpReward = 0
        isPersonalized = false
    }

    // MARK: - Methods

    /// Update progress and check if quest is completed
    @discardableResult
    public func updateProgress(to value: Int) -> Bool {
        currentProgress = value
        if currentProgress >= targetValue && !isCompleted {
            complete()
            return true
        }
        return false
    }

    /// Complete the quest
    public func complete() {
        isCompleted = true
        completedAt = Date()
    }
}

// MARK: - Quest Enums

public enum QuestType: String, Codable {
    case consistency
    case exploration
    case emotionalAwareness
    case reflection
    case gratitude
    case energy
    case creativity
    case relationships

    public var displayName: String {
        rawValue.capitalized
    }
}

public enum QuestDuration: String, Codable {
    case daily
    case weekly
    case monthly
    case custom
}

// MARK: - UserProfile Model

/// Stores user-level data, preferences, and gamification state
@objc(UserProfile)
public class UserProfile: NSManagedObject, Identifiable {

    // MARK: - Identity

    @NSManaged public var id: UUID
    @NSManaged public var createdAt: Date

    // MARK: - Gamification

    @NSManaged public var level: Int
    @NSManaged public var totalXP: Int
    @NSManaged public var currentStreak: Int
    @NSManaged public var longestStreak: Int
    @NSManaged public var lastNoteDate: Date?
    @NSManaged public var streakFreezes: Int  // Available streak freeze tokens

    // MARK: - Garden State (JSON)

    @NSManaged private var gardenStateJSON: String?

    public var gardenState: GardenState {
        get {
            guard let json = gardenStateJSON,
                  let data = json.data(using: .utf8),
                  let state = try? JSONDecoder().decode(GardenState.self, from: data) else {
                return GardenState()
            }
            return state
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue),
                  let json = String(data: data, encoding: .utf8) else {
                gardenStateJSON = nil
                return
            }
            gardenStateJSON = json
        }
    }

    // MARK: - Preferences

    @NSManaged public var preferredLanguage: String
    @NSManaged private var preferredThemeRaw: String
    @NSManaged private var notificationSettingsJSON: String?

    public var preferredTheme: ThemePreference {
        get {
            ThemePreference(rawValue: preferredThemeRaw) ?? .auto
        }
        set {
            preferredThemeRaw = newValue.rawValue
        }
    }

    public var notificationSettings: NotificationSettings {
        get {
            guard let json = notificationSettingsJSON,
                  let data = json.data(using: .utf8),
                  let settings = try? JSONDecoder().decode(NotificationSettings.self, from: data) else {
                return NotificationSettings()
            }
            return settings
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue),
                  let json = String(data: data, encoding: .utf8) else {
                notificationSettingsJSON = nil
                return
            }
            notificationSettingsJSON = json
        }
    }

    // MARK: - Privacy Settings

    @NSManaged private var dataProcessingPreferenceRaw: String
    @NSManaged public var syncEnabled: Bool
    @NSManaged public var healthKitEnabled: Bool
    @NSManaged public var locationServicesEnabled: Bool

    public var dataProcessingPreference: DataProcessingPreference {
        get {
            DataProcessingPreference(rawValue: dataProcessingPreferenceRaw) ?? .onDeviceOnly
        }
        set {
            dataProcessingPreferenceRaw = newValue.rawValue
        }
    }

    // MARK: - Subscription

    @NSManaged private var subscriptionTierRaw: String
    @NSManaged public var subscriptionExpiresAt: Date?
    @NSManaged public var isLifetimeMember: Bool

    public var subscriptionTier: SubscriptionTier {
        get {
            SubscriptionTier(rawValue: subscriptionTierRaw) ?? .free
        }
        set {
            subscriptionTierRaw = newValue.rawValue
        }
    }

    // MARK: - Statistics

    @NSManaged public var totalNotes: Int
    @NSManaged public var totalWords: Int
    @NSManaged public var totalAudioMinutes: Int
    @NSManaged public var totalEntitiesDetected: Int

    // MARK: - Relationships

    @NSManaged public var achievements: Set<Achievement>
    @NSManaged public var activeQuests: Set<Quest>

    // MARK: - Computed Properties

    public var isPro: Bool {
        subscriptionTier == .pro || subscriptionTier == .family || isLifetimeMember
    }

    public var xpForNextLevel: Int {
        // XP required for next level (exponential growth)
        level * 100 + (level * level) * 10
    }

    public var xpProgress: Double {
        let currentLevelXP = (level - 1) * 100 + ((level - 1) * (level - 1)) * 10
        let nextLevelXP = xpForNextLevel
        let progress = Double(totalXP - currentLevelXP) / Double(nextLevelXP - currentLevelXP)
        return max(0, min(1, progress))
    }

    public var unlockedAchievements: [Achievement] {
        achievements.filter { $0.isCompleted }.sorted { $0.unlockedAt ?? Date.distantPast > $1.unlockedAt ?? Date.distantPast }
    }

    public var lockedAchievements: [Achievement] {
        achievements.filter { !$0.isCompleted }.sorted { $0.progressPercentage > $1.progressPercentage }
    }

    // MARK: - Initialization

    public override func awakeFromInsert() {
        super.awakeFromInsert()

        id = UUID()
        createdAt = Date()
        level = 1
        totalXP = 0
        currentStreak = 0
        longestStreak = 0
        streakFreezes = 2  // Start with 2 streak freezes
        preferredLanguage = "en"
        preferredTheme = .auto
        dataProcessingPreference = .onDeviceOnly
        syncEnabled = false
        healthKitEnabled = false
        locationServicesEnabled = false
        subscriptionTier = .free
        isLifetimeMember = false
        totalNotes = 0
        totalWords = 0
        totalAudioMinutes = 0
        totalEntitiesDetected = 0
        achievements = Set()
        activeQuests = Set()
    }

    // MARK: - Methods

    /// Award XP and check for level up
    @discardableResult
    public func awardXP(_ amount: Int) -> Bool {
        totalXP += amount
        if totalXP >= xpForNextLevel {
            levelUp()
            return true
        }
        return false
    }

    /// Level up the user
    public func levelUp() {
        level += 1
        // Award streak freeze on level up
        if level % 5 == 0 {
            streakFreezes += 1
        }
    }

    /// Update streak based on last note date
    public func updateStreak() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        guard let lastDate = lastNoteDate else {
            // First note ever
            currentStreak = 1
            lastNoteDate = today
            return
        }

        let lastNoteDay = calendar.startOfDay(for: lastDate)
        let daysBetween = calendar.dateComponents([.day], from: lastNoteDay, to: today).day ?? 0

        if daysBetween == 0 {
            // Already noted today
            return
        } else if daysBetween == 1 {
            // Consecutive day
            currentStreak += 1
            longestStreak = max(longestStreak, currentStreak)
        } else if daysBetween > 1 && streakFreezes > 0 {
            // Missed day(s) but has streak freeze
            // User can choose to use freeze
            // (This would be handled in UI)
            return
        } else {
            // Streak broken
            currentStreak = 1
        }

        lastNoteDate = today
    }

    /// Use a streak freeze
    public func useStreakFreeze() -> Bool {
        guard streakFreezes > 0 else { return false }
        streakFreezes -= 1
        return true
    }
}

// MARK: - Supporting Structs & Enums

public struct GardenState: Codable {
    public var trees: [GardenTree] = []
    public var flowers: [GardenFlower] = []
    public var vines: [GardenVine] = []
    public var crystals: [GardenCrystal] = []
    public var season: Season = .spring

    public init() {}
}

public struct GardenTree: Codable, Identifiable {
    public let id: UUID
    public var type: String
    public var growthLevel: Int
    public var position: CGPoint

    public init(id: UUID = UUID(), type: String, growthLevel: Int, position: CGPoint) {
        self.id = id
        self.type = type
        self.growthLevel = growthLevel
        self.position = position
    }
}

public struct GardenFlower: Codable, Identifiable {
    public let id: UUID
    public var type: String
    public var bloomLevel: Int
    public var position: CGPoint

    public init(id: UUID = UUID(), type: String, bloomLevel: Int, position: CGPoint) {
        self.id = id
        self.type = type
        self.bloomLevel = bloomLevel
        self.position = position
    }
}

public struct GardenVine: Codable, Identifiable {
    public let id: UUID
    public var type: String
    public var length: Int
    public var position: CGPoint

    public init(id: UUID = UUID(), type: String, length: Int, position: CGPoint) {
        self.id = id
        self.type = type
        self.length = length
        self.position = position
    }
}

public struct GardenCrystal: Codable, Identifiable {
    public let id: UUID
    public var type: String
    public var brightness: Double
    public var position: CGPoint

    public init(id: UUID = UUID(), type: String, brightness: Double, position: CGPoint) {
        self.id = id
        self.type = type
        self.brightness = brightness
        self.position = position
    }
}

public enum Season: String, Codable {
    case spring
    case summer
    case autumn
    case winter
}

public struct NotificationSettings: Codable {
    public var dailyReminderEnabled: Bool = false
    public var dailyReminderTime: Date?
    public var insightNotificationsEnabled: Bool = true
    public var achievementNotificationsEnabled: Bool = true
    public var streakReminderEnabled: Bool = true

    public init() {}
}

public enum ThemePreference: String, Codable {
    case light
    case dark
    case auto
    case moodAdaptive

    public var displayName: String {
        switch self {
        case .light: return "Light"
        case .dark: return "Dark"
        case .auto: return "Auto"
        case .moodAdaptive: return "Mood Adaptive"
        }
    }
}

public enum DataProcessingPreference: String, Codable {
    case onDeviceOnly
    case hybridOptIn

    public var displayName: String {
        switch self {
        case .onDeviceOnly: return "On-Device Only"
        case .hybridOptIn: return "Hybrid (Cloud AI Enabled)"
        }
    }
}

public enum SubscriptionTier: String, Codable {
    case free
    case pro
    case family
    case lifetime

    public var displayName: String {
        switch self {
        case .free: return "Free"
        case .pro: return "Pro"
        case .family: return "Family"
        case .lifetime: return "Lifetime"
        }
    }
}

// MARK: - CGPoint Codable Extension

import CoreGraphics

extension CGPoint: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let x = try container.decode(CGFloat.self, forKey: .x)
        let y = try container.decode(CGFloat.self, forKey: .y)
        self.init(x: x, y: y)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(x, forKey: .x)
        try container.encode(y, forKey: .y)
    }

    private enum CodingKeys: String, CodingKey {
        case x, y
    }
}

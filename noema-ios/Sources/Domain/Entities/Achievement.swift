import Foundation

/// Represents a gamification achievement that users can unlock
public struct Achievement: Identifiable, Equatable, Codable, Sendable, Hashable {
    // MARK: - Properties

    public let id: String // Unique identifier (e.g., "first_note")
    public let type: AchievementType
    public let tier: AchievementTier
    public let title: String
    public let description: String
    public let iconName: String // SF Symbol name
    public var unlockedAt: Date?
    public var progress: Float // 0.0 - 1.0
    public let isHidden: Bool

    // MARK: - Initialization

    public init(
        id: String,
        type: AchievementType,
        tier: AchievementTier,
        title: String,
        description: String,
        iconName: String,
        unlockedAt: Date? = nil,
        progress: Float = 0.0,
        isHidden: Bool = false
    ) {
        self.id = id
        self.type = type
        self.tier = tier
        self.title = title
        self.description = description
        self.iconName = iconName
        self.unlockedAt = unlockedAt
        self.progress = min(1.0, max(0.0, progress)) // Clamp to [0, 1]
        self.isHidden = isHidden
    }

    // MARK: - Computed Properties

    /// Is achievement unlocked?
    public var isUnlocked: Bool {
        unlockedAt != nil
    }

    /// Progress as percentage (0-100)
    public var progressPercentage: Int {
        Int(progress * 100)
    }

    /// Color hex for tier
    public var tierColorHex: String {
        tier.colorHex
    }

    /// Experience points awarded for unlock
    public var experienceReward: Int {
        tier.experienceReward
    }

    // MARK: - Business Logic

    /// Update progress toward unlock
    public mutating func updateProgress(_ newProgress: Float) {
        progress = min(1.0, max(0.0, newProgress))

        // Auto-unlock if progress reaches 100%
        if progress >= 1.0 && unlockedAt == nil {
            unlock()
        }
    }

    /// Unlock the achievement
    public mutating func unlock() {
        guard unlockedAt == nil else { return }
        unlockedAt = Date()
        progress = 1.0
    }

    /// Check if achievement was recently unlocked (within last 24 hours)
    public var isRecentlyUnlocked: Bool {
        guard let unlocked = unlockedAt else { return false }
        return Date().timeIntervalSince(unlocked) < 24 * 3600
    }
}

// MARK: - Achievement Type

public enum AchievementType: String, Codable, Sendable, CaseIterable {
    case milestone      // First note, 100th note, etc.
    case streak         // 7-day streak, 30-day streak
    case quantity       // Create 100 notes
    case wellness       // Emotional balance
    case discovery      // Try new features
    case mastery        // Use advanced features
    case social         // Share achievements
    case special        // Limited-time events

    public var label: String {
        switch self {
        case .milestone: return "Milestone"
        case .streak: return "Streak"
        case .quantity: return "Quantity"
        case .wellness: return "Wellness"
        case .discovery: return "Discovery"
        case .mastery: return "Mastery"
        case .social: return "Social"
        case .special: return "Special"
        }
    }
}

// MARK: - Achievement Tier

public enum AchievementTier: String, Codable, Sendable, CaseIterable, Comparable {
    case bronze
    case silver
    case gold
    case platinum
    case legendary

    public var label: String {
        rawValue.capitalized
    }

    public var colorHex: String {
        switch self {
        case .bronze: return "#CD7F32"
        case .silver: return "#C0C0C0"
        case .gold: return "#FFD700"
        case .platinum: return "#E5E4E2"
        case .legendary: return "#FF00FF"
        }
    }

    public var experienceReward: Int {
        switch self {
        case .bronze: return 10
        case .silver: return 25
        case .gold: return 50
        case .platinum: return 100
        case .legendary: return 250
        }
    }

    public static func < (lhs: AchievementTier, rhs: AchievementTier) -> Bool {
        let order: [AchievementTier] = [.bronze, .silver, .gold, .platinum, .legendary]
        guard let lhsIndex = order.firstIndex(of: lhs),
              let rhsIndex = order.firstIndex(of: rhs) else {
            return false
        }
        return lhsIndex < rhsIndex
    }
}

// MARK: - Predefined Achievements

extension Achievement {
    public static let allAchievements: [Achievement] = [
        // MARK: Milestone Achievements

        Achievement(
            id: "first_note",
            type: .milestone,
            tier: .bronze,
            title: "First Steps",
            description: "Create your first note",
            iconName: "1.circle.fill"
        ),

        Achievement(
            id: "tenth_note",
            type: .milestone,
            tier: .bronze,
            title: "Getting Started",
            description: "Create 10 notes",
            iconName: "10.circle.fill"
        ),

        Achievement(
            id: "hundredth_note",
            type: .milestone,
            tier: .gold,
            title: "Centurion",
            description: "Create 100 notes",
            iconName: "100.circle.fill"
        ),

        // MARK: Streak Achievements

        Achievement(
            id: "streak_7",
            type: .streak,
            tier: .silver,
            title: "Week Warrior",
            description: "Maintain a 7-day streak",
            iconName: "flame.fill"
        ),

        Achievement(
            id: "streak_30",
            type: .streak,
            tier: .gold,
            title: "Monthly Master",
            description: "Maintain a 30-day streak",
            iconName: "flame.circle.fill"
        ),

        Achievement(
            id: "streak_100",
            type: .streak,
            tier: .platinum,
            title: "Consistency Champion",
            description: "Maintain a 100-day streak",
            iconName: "star.fill"
        ),

        // MARK: Wellness Achievements

        Achievement(
            id: "mood_balance",
            type: .wellness,
            tier: .platinum,
            title: "Emotional Balance",
            description: "Maintain balanced moods for 30 days",
            iconName: "chart.xyaxis.line"
        ),

        Achievement(
            id: "mindful_week",
            type: .wellness,
            tier: .silver,
            title: "Mindful Week",
            description: "Log moods every day for 7 days",
            iconName: "brain.head.profile"
        ),

        Achievement(
            id: "gratitude_master",
            type: .wellness,
            tier: .gold,
            title: "Gratitude Master",
            description: "Create 50 gratitude notes",
            iconName: "heart.fill"
        ),

        // MARK: Discovery Achievements

        Achievement(
            id: "voice_recorder",
            type: .discovery,
            tier: .bronze,
            title: "Voice Explorer",
            description: "Record your first voice note",
            iconName: "mic.fill"
        ),

        Achievement(
            id: "mood_tracker",
            type: .discovery,
            tier: .bronze,
            title: "Emotion Detective",
            description: "Use mood tracking for the first time",
            iconName: "face.smiling.fill"
        ),

        Achievement(
            id: "integration_master",
            type: .discovery,
            tier: .silver,
            title: "Connected Life",
            description: "Enable HealthKit, Calendar, and Music integrations",
            iconName: "link.circle.fill"
        ),

        // MARK: Social Achievements

        Achievement(
            id: "first_share",
            type: .social,
            tier: .bronze,
            title: "Sharer",
            description: "Share an achievement for the first time",
            iconName: "square.and.arrow.up.fill"
        ),

        // MARK: Special/Hidden Achievements

        Achievement(
            id: "midnight_writer",
            type: .special,
            tier: .silver,
            title: "Night Owl",
            description: "Create a note between midnight and 3 AM",
            iconName: "moon.stars.fill",
            isHidden: true
        ),

        Achievement(
            id: "founder",
            type: .special,
            tier: .legendary,
            title: "Founder",
            description: "Among the first 1,000 users",
            iconName: "star.circle.fill",
            isHidden: false
        ),
    ]
}

// MARK: - Sample Data

#if DEBUG
extension Achievement {
    public static var sample: Achievement {
        var achievement = allAchievements[0]
        achievement.unlock()
        return achievement
    }

    public static var sampleInProgress: Achievement {
        var achievement = allAchievements[1]
        achievement.updateProgress(0.6)
        return achievement
    }

    public static var sampleLocked: Achievement {
        allAchievements[2]
    }
}
#endif

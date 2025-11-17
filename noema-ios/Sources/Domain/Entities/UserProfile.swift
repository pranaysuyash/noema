import Foundation

/// Represents a user's profile with gamification stats
public struct UserProfile: Identifiable, Equatable, Codable, Sendable {
    // MARK: - Properties

    public let id: UUID
    public let createdAt: Date
    public var displayName: String?
    public var avatarURL: URL?

    // MARK: - Gamification Stats

    public var level: Int
    public var experience: Int
    public var streak: Int
    public var longestStreak: Int
    public var totalNotes: Int
    public var totalMoods: Int
    public var lastNoteDate: Date?

    // MARK: - Initialization

    public init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        displayName: String? = nil,
        avatarURL: URL? = nil,
        level: Int = 1,
        experience: Int = 0,
        streak: Int = 0,
        longestStreak: Int = 0,
        totalNotes: Int = 0,
        totalMoods: Int = 0,
        lastNoteDate: Date? = nil
    ) {
        self.id = id
        self.createdAt = createdAt
        self.displayName = displayName
        self.avatarURL = avatarURL
        self.level = level
        self.experience = experience
        self.streak = streak
        self.longestStreak = longestStreak
        self.totalNotes = totalNotes
        self.totalMoods = totalMoods
        self.lastNoteDate = lastNoteDate
    }

    // MARK: - Computed Properties

    /// Experience required for next level
    public var experienceForNextLevel: Int {
        // Exponential curve: 100 * level^1.5
        Int(100.0 * pow(Double(level), 1.5))
    }

    /// Progress toward next level (0.0 - 1.0)
    public var levelProgress: Double {
        guard experienceForNextLevel > 0 else { return 0.0 }
        return Double(experience) / Double(experienceForNextLevel)
    }

    /// Experience remaining until next level
    public var experienceUntilNextLevel: Int {
        max(0, experienceForNextLevel - experience)
    }

    /// Check if user is a beginner (level 1-5)
    public var isBeginner: Bool {
        level < 6
    }

    /// Check if user is intermediate (level 6-15)
    public var isIntermediate: Bool {
        level >= 6 && level < 16
    }

    /// Check if user is advanced (level 16-30)
    public var isAdvanced: Bool {
        level >= 16 && level < 31
    }

    /// Check if user is expert (level 31+)
    public var isExpert: Bool {
        level >= 31
    }

    /// Tier label based on level
    public var tierLabel: String {
        switch level {
        case 1...5:
            return "Beginner"
        case 6...15:
            return "Reflector"
        case 16...30:
            return "Mindful"
        case 31...50:
            return "Master"
        default:
            return "Legend"
        }
    }

    /// Days since account creation
    public var accountAge: Int {
        Calendar.current.dateComponents([.day], from: createdAt, to: Date()).day ?? 0
    }

    /// Average notes per day
    public var averageNotesPerDay: Double {
        guard accountAge > 0 else { return 0.0 }
        return Double(totalNotes) / Double(accountAge)
    }

    // MARK: - Business Logic

    /// Update streak based on current date and last note date
    public mutating func updateStreak() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        guard let lastDate = lastNoteDate else {
            // First note ever
            streak = 1
            lastNoteDate = today
            return
        }

        let lastNoteDay = calendar.startOfDay(for: lastDate)
        let daysSinceLastNote = calendar.dateComponents([.day], from: lastNoteDay, to: today).day ?? 0

        if daysSinceLastNote == 0 {
            // Same day, no change to streak
            return
        } else if daysSinceLastNote == 1 {
            // Consecutive day, increment streak
            streak += 1
        } else {
            // Streak broken
            streak = 1
        }

        lastNoteDate = today

        // Update longest streak if current is longer
        if streak > longestStreak {
            longestStreak = streak
        }
    }

    /// Add experience points
    public mutating func addExperience(points: Int) {
        experience += points
    }

    /// Check if user leveled up after adding experience
    /// Returns true if level increased
    public mutating func checkLevelUp() -> Bool {
        guard experience >= experienceForNextLevel else {
            return false
        }

        level += 1
        experience -= experienceForNextLevel
        return true
    }

    /// Increment total notes count
    public mutating func incrementNoteCount() {
        totalNotes += 1
    }

    /// Increment total moods count
    public mutating func incrementMoodCount() {
        totalMoods += 1
    }

    /// Use streak protection (e.g., sick day)
    /// Returns true if protection was applied
    public mutating func useStreakProtection() -> Bool {
        // TODO: Implement streak protection logic
        // For now, just maintain current streak
        return true
    }
}

// MARK: - Sample Data

#if DEBUG
extension UserProfile {
    public static var sample: UserProfile {
        UserProfile(
            displayName: "Alex Johnson",
            level: 12,
            experience: 450,
            streak: 7,
            longestStreak: 23,
            totalNotes: 156,
            totalMoods: 203,
            lastNoteDate: Date()
        )
    }

    public static var beginner: UserProfile {
        UserProfile(
            displayName: "New User",
            level: 1,
            experience: 0,
            streak: 0,
            longestStreak: 0,
            totalNotes: 0,
            totalMoods: 0
        )
    }

    public static var expert: UserProfile {
        UserProfile(
            displayName: "Expert User",
            level: 35,
            experience: 1200,
            streak: 45,
            longestStreak: 65,
            totalNotes: 1250,
            totalMoods: 1800,
            lastNoteDate: Date()
        )
    }
}
#endif

import Foundation

/// User preferences and settings
public struct Preferences: Equatable, Codable, Sendable {
    // MARK: - Cloud & Sync

    public var cloudSyncEnabled: Bool
    public var cloudAIEnabled: Bool

    // MARK: - Security

    public var biometricAuthEnabled: Bool
    public var privacyMode: Bool // Hide content in app switcher

    // MARK: - AI Features

    public var autoMoodDetection: Bool
    public var voiceMoodDetection: Bool
    public var autoSummarization: Bool
    public var autoEntityExtraction: Bool

    // MARK: - Notifications

    public var notificationsEnabled: Bool
    public var dailyReminderEnabled: Bool
    public var reminderTime: Date?
    public var streakRemindersEnabled: Bool
    public var achievementNotificationsEnabled: Bool

    // MARK: - Appearance

    public var theme: Theme
    public var accentColor: String // Hex color
    public var useSystemTextSize: Bool

    // MARK: - Integrations

    public var healthKitEnabled: Bool
    public var calendarEnabled: Bool
    public var musicEnabled: Bool

    // MARK: - Privacy

    public var shareAnalytics: Bool
    public var shareCrashReports: Bool
    public var dataResidency: DataResidency

    // MARK: - Initialization

    public init(
        cloudSyncEnabled: Bool = false,
        cloudAIEnabled: Bool = false,
        biometricAuthEnabled: Bool = true,
        privacyMode: Bool = false,
        autoMoodDetection: Bool = true,
        voiceMoodDetection: Bool = true,
        autoSummarization: Bool = true,
        autoEntityExtraction: Bool = true,
        notificationsEnabled: Bool = true,
        dailyReminderEnabled: Bool = false,
        reminderTime: Date? = nil,
        streakRemindersEnabled: Bool = true,
        achievementNotificationsEnabled: Bool = true,
        theme: Theme = .system,
        accentColor: String = "#3498DB",
        useSystemTextSize: Bool = true,
        healthKitEnabled: Bool = false,
        calendarEnabled: Bool = false,
        musicEnabled: Bool = false,
        shareAnalytics: Bool = false,
        shareCrashReports: Bool = true,
        dataResidency: DataResidency = .auto
    ) {
        self.cloudSyncEnabled = cloudSyncEnabled
        self.cloudAIEnabled = cloudAIEnabled
        self.biometricAuthEnabled = biometricAuthEnabled
        self.privacyMode = privacyMode
        self.autoMoodDetection = autoMoodDetection
        self.voiceMoodDetection = voiceMoodDetection
        self.autoSummarization = autoSummarization
        self.autoEntityExtraction = autoEntityExtraction
        self.notificationsEnabled = notificationsEnabled
        self.dailyReminderEnabled = dailyReminderEnabled
        self.reminderTime = reminderTime
        self.streakRemindersEnabled = streakRemindersEnabled
        self.achievementNotificationsEnabled = achievementNotificationsEnabled
        self.theme = theme
        self.accentColor = accentColor
        self.useSystemTextSize = useSystemTextSize
        self.healthKitEnabled = healthKitEnabled
        self.calendarEnabled = calendarEnabled
        self.musicEnabled = musicEnabled
        self.shareAnalytics = shareAnalytics
        self.shareCrashReports = shareCrashReports
        self.dataResidency = dataResidency
    }
}

// MARK: - Theme

public enum Theme: String, Codable, Sendable, CaseIterable {
    case light
    case dark
    case system

    public var label: String {
        switch self {
        case .light:
            return "Light"
        case .dark:
            return "Dark"
        case .system:
            return "System"
        }
    }

    public var iconName: String {
        switch self {
        case .light:
            return "sun.max.fill"
        case .dark:
            return "moon.fill"
        case .system:
            return "gear"
        }
    }
}

// MARK: - Data Residency

public enum DataResidency: String, Codable, Sendable, CaseIterable {
    case auto // Choose automatically based on user location
    case us // United States
    case eu // European Union
    case asia // Asia Pacific

    public var label: String {
        switch self {
        case .auto:
            return "Automatic"
        case .us:
            return "United States"
        case .eu:
            return "European Union"
        case .asia:
            return "Asia Pacific"
        }
    }

    public var description: String {
        switch self {
        case .auto:
            return "Data stored in region closest to you"
        case .us:
            return "Data stored in US data centers"
        case .eu:
            return "Data stored in EU data centers (GDPR compliant)"
        case .asia:
            return "Data stored in Asia Pacific data centers"
        }
    }
}

// MARK: - Sample Data

#if DEBUG
extension Preferences {
    public static var sample: Preferences {
        Preferences(
            cloudSyncEnabled: true,
            healthKitEnabled: true,
            calendarEnabled: true
        )
    }

    public static var privacyFocused: Preferences {
        Preferences(
            cloudSyncEnabled: false,
            cloudAIEnabled: false,
            privacyMode: true,
            shareAnalytics: false
        )
    }

    public static var fullFeatured: Preferences {
        Preferences(
            cloudSyncEnabled: true,
            cloudAIEnabled: true,
            healthKitEnabled: true,
            calendarEnabled: true,
            musicEnabled: true,
            shareAnalytics: true
        )
    }
}
#endif

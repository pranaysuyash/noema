import SwiftUI

/// Coordinator for settings and configuration flows
/// Manages navigation between settings, privacy, AI controls, and account management
@MainActor
public final class SettingsCoordinator: Coordinator {
    // MARK: - Coordinator Protocol

    public var parent: (any Coordinator)?
    public var children: [any Coordinator] = []

    // MARK: - Published Properties

    @Published public var navigationPath = NavigationPath()
    @Published public var isPresentingAccountDeletion: Bool = false
    @Published public var isPresentingDataExport: Bool = false
    @Published public var isPresentingAbout: Bool = false
    @Published public var isPresentingSupport: Bool = false

    // MARK: - Dependencies

    private let userProfileRepository: UserProfileRepositoryProtocol

    // MARK: - Initialization

    public init(
        userProfileRepository: UserProfileRepositoryProtocol,
        parent: (any Coordinator)? = nil
    ) {
        self.userProfileRepository = userProfileRepository
        self.parent = parent
    }

    // MARK: - Coordinator Protocol

    public func start() {
        // Initial setup for settings flow
    }

    // MARK: - Navigation

    public func navigate(to destination: NavigationDestination) {
        switch destination {
        case .settings:
            popToRoot()

        case .privacyDashboard:
            showPrivacyDashboard()

        case .aiControls:
            showAIControls()

        default:
            break
        }
    }

    public func showPrivacyDashboard() {
        navigationPath.append(NavigationDestination.privacyDashboard)
    }

    public func showAIControls() {
        navigationPath.append(NavigationDestination.aiControls)
    }

    public func showAbout() {
        isPresentingAbout = true
    }

    public func showSupport() {
        isPresentingSupport = true
    }

    public func showAccountDeletion() {
        isPresentingAccountDeletion = true
    }

    public func showDataExport() {
        isPresentingDataExport = true
    }

    public func dismissAbout() {
        isPresentingAbout = false
    }

    public func dismissSupport() {
        isPresentingSupport = false
    }

    public func dismissAccountDeletion() {
        isPresentingAccountDeletion = false
    }

    public func dismissDataExport() {
        isPresentingDataExport = false
    }

    public func popToRoot() {
        navigationPath.removeLast(navigationPath.count)
    }

    // MARK: - Settings Actions

    public func updateNotificationSettings(_ settings: NotificationSettings) {
        UserDefaults.standard.set(settings.dailyReminder, forKey: "notifications_dailyReminder")
        UserDefaults.standard.set(settings.streakReminder, forKey: "notifications_streakReminder")
        UserDefaults.standard.set(settings.achievementUnlocked, forKey: "notifications_achievementUnlocked")
        UserDefaults.standard.set(settings.moodCheckIn, forKey: "notifications_moodCheckIn")
    }

    public func updatePrivacySettings(_ settings: PrivacySettings) {
        UserDefaults.standard.set(settings.cloudSyncEnabled, forKey: "cloudSyncEnabled")
        UserDefaults.standard.set(settings.analyticsEnabled, forKey: "analyticsEnabled")
        UserDefaults.standard.set(settings.crashReportingEnabled, forKey: "crashReportingEnabled")
        UserDefaults.standard.set(settings.biometricsEnabled, forKey: "biometricsEnabled")
    }

    public func updateAISettings(_ settings: AISettings) {
        UserDefaults.standard.set(settings.moodDetectionEnabled, forKey: "ai_moodDetectionEnabled")
        UserDefaults.standard.set(settings.autoSummarization, forKey: "ai_autoSummarization")
        UserDefaults.standard.set(settings.entityExtraction, forKey: "ai_entityExtraction")
        UserDefaults.standard.set(settings.useCloudAI, forKey: "ai_useCloudAI")
        UserDefaults.standard.set(settings.preferredLanguage, forKey: "ai_preferredLanguage")
    }

    public func updateAppearanceSettings(_ settings: AppearanceSettings) {
        UserDefaults.standard.set(settings.theme.rawValue, forKey: "appearance_theme")
        UserDefaults.standard.set(settings.accentColor, forKey: "appearance_accentColor")
        UserDefaults.standard.set(settings.fontSize.rawValue, forKey: "appearance_fontSize")
    }

    // MARK: - Data Management

    public func exportAllData() async throws -> URL {
        // Create comprehensive data export
        let exportData = ExportData(
            exportDate: Date(),
            version: "1.0",
            userData: try await exportUserData(),
            notes: [],  // Would fetch all notes
            moods: [],  // Would fetch all moods
            achievements: [],  // Would fetch all achievements
            tags: []  // Would fetch all tags
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        let fileName = "noema-export-\(Date().ISO8601Format()).json"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        let data = try encoder.encode(exportData)
        try data.write(to: tempURL)

        return tempURL
    }

    public func deleteAllData() async throws {
        // This would delete all user data
        // Implementation would involve calling delete methods on all repositories
        // For now, this is a placeholder
        throw CoordinatorError.invalidTransition
    }

    public func deleteAccount() async throws {
        // Delete account from backend and all local data
        // Implementation would involve:
        // 1. Backend API call to delete account
        // 2. Delete all local data
        // 3. Sign out user
        throw CoordinatorError.invalidTransition
    }

    // MARK: - Support

    public func sendFeedback(_ feedback: String, category: FeedbackCategory) async throws {
        // Send feedback to backend
        // For now, this would open mail client or support form
        let subject = "noema Feedback: \(category.rawValue)"
        let body = feedback

        // In production, this would send to support API
        print("Feedback submitted: \(subject)")
    }

    public func reportBug(_ description: String, severity: BugSeverity) async throws {
        // Report bug with device info and logs
        let deviceInfo = """
        Device: \(UIDevice.current.model)
        iOS Version: \(UIDevice.current.systemVersion)
        App Version: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown")
        Build: \(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "unknown")
        """

        print("Bug reported [\(severity.rawValue)]: \(description)\n\(deviceInfo)")
    }

    // MARK: - Private Helpers

    private func exportUserData() async throws -> UserData {
        let profile = try await userProfileRepository.fetch()

        return UserData(
            id: profile?.id ?? UUID(),
            name: profile?.name,
            email: profile?.email,
            createdAt: Date(),  // Would come from profile
            level: profile?.level ?? 1,
            experience: profile?.experience ?? 0,
            streak: profile?.streak ?? 0,
            longestStreak: profile?.longestStreak ?? 0
        )
    }
}

// MARK: - Settings Models

public struct NotificationSettings: Codable {
    public var dailyReminder: Bool
    public var streakReminder: Bool
    public var achievementUnlocked: Bool
    public var moodCheckIn: Bool

    public static var `default`: NotificationSettings {
        NotificationSettings(
            dailyReminder: true,
            streakReminder: true,
            achievementUnlocked: true,
            moodCheckIn: true
        )
    }
}

public struct PrivacySettings: Codable {
    public var cloudSyncEnabled: Bool
    public var analyticsEnabled: Bool
    public var crashReportingEnabled: Bool
    public var biometricsEnabled: Bool

    public static var `default`: PrivacySettings {
        PrivacySettings(
            cloudSyncEnabled: false,  // Opt-in
            analyticsEnabled: true,
            crashReportingEnabled: true,
            biometricsEnabled: true
        )
    }
}

public struct AISettings: Codable {
    public var moodDetectionEnabled: Bool
    public var autoSummarization: Bool
    public var entityExtraction: Bool
    public var useCloudAI: Bool
    public var preferredLanguage: String

    public static var `default`: AISettings {
        AISettings(
            moodDetectionEnabled: true,
            autoSummarization: true,
            entityExtraction: true,
            useCloudAI: false,  // On-device by default
            preferredLanguage: "en"
        )
    }
}

public struct AppearanceSettings: Codable {
    public var theme: Theme
    public var accentColor: String
    public var fontSize: FontSize

    public enum Theme: String, Codable, CaseIterable {
        case system
        case light
        case dark

        public var displayName: String {
            switch self {
            case .system: return "System"
            case .light: return "Light"
            case .dark: return "Dark"
            }
        }
    }

    public enum FontSize: String, Codable, CaseIterable {
        case small
        case medium
        case large
        case extraLarge

        public var displayName: String {
            switch self {
            case .small: return "Small"
            case .medium: return "Medium"
            case .large: return "Large"
            case .extraLarge: return "Extra Large"
            }
        }

        public var scaleFactor: CGFloat {
            switch self {
            case .small: return 0.9
            case .medium: return 1.0
            case .large: return 1.1
            case .extraLarge: return 1.2
            }
        }
    }

    public static var `default`: AppearanceSettings {
        AppearanceSettings(
            theme: .system,
            accentColor: "blue",
            fontSize: .medium
        )
    }
}

// MARK: - Export Models

public struct ExportData: Codable {
    public let exportDate: Date
    public let version: String
    public let userData: UserData
    public let notes: [Note]
    public let moods: [MoodSnapshot]
    public let achievements: [Achievement]
    public let tags: [Tag]
}

public struct UserData: Codable {
    public let id: UUID
    public let name: String?
    public let email: String?
    public let createdAt: Date
    public let level: Int
    public let experience: Int
    public let streak: Int
    public let longestStreak: Int
}

// MARK: - Feedback Models

public enum FeedbackCategory: String, CaseIterable {
    case general
    case featureRequest
    case bug
    case performance
    case privacy
    case other

    public var displayName: String {
        switch self {
        case .general: return "General Feedback"
        case .featureRequest: return "Feature Request"
        case .bug: return "Bug Report"
        case .performance: return "Performance Issue"
        case .privacy: return "Privacy Concern"
        case .other: return "Other"
        }
    }
}

public enum BugSeverity: String, CaseIterable {
    case low
    case medium
    case high
    case critical

    public var displayName: String {
        switch self {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        case .critical: return "Critical"
        }
    }
}

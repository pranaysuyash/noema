import SwiftUI

/// ViewModel for settings screen
/// Manages all app settings and preferences
@MainActor
public final class SettingsViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published public var notificationSettings: NotificationSettings
    @Published public var appearanceSettings: AppearanceSettings
    @Published public var userProfile: UserProfile?
    @Published public var isLoading: Bool = false
    @Published public var error: Error?
    @Published public var showingLogoutConfirmation: Bool = false

    // MARK: - Dependencies

    private let userProfileRepository: UserProfileRepositoryProtocol

    // MARK: - Initialization

    public init(userProfileRepository: UserProfileRepositoryProtocol) {
        self.userProfileRepository = userProfileRepository
        self.notificationSettings = Self.loadNotificationSettings()
        self.appearanceSettings = Self.loadAppearanceSettings()
    }

    // MARK: - Public Methods

    public func loadSettings() async {
        isLoading = true
        error = nil

        do {
            userProfile = try await userProfileRepository.fetch()
        } catch {
            self.error = error
        }

        isLoading = false
    }

    public func updateNotificationSettings(_ settings: NotificationSettings) {
        notificationSettings = settings
        Self.saveNotificationSettings(settings)
    }

    public func updateAppearanceSettings(_ settings: AppearanceSettings) {
        appearanceSettings = settings
        Self.saveAppearanceSettings(settings)
        applyAppearance(settings)
    }

    public func logout() {
        // TODO: Implement logout logic
        UserDefaults.standard.set(false, forKey: "isAuthenticated")
    }

    public func confirmLogout() {
        showingLogoutConfirmation = true
    }

    // MARK: - Private Methods

    private func applyAppearance(_ settings: AppearanceSettings) {
        // Apply theme
        switch settings.theme {
        case .system:
            UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .unspecified
        case .light:
            UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .light
        case .dark:
            UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .dark
        }
    }

    // MARK: - Static Helpers

    private static func loadNotificationSettings() -> NotificationSettings {
        NotificationSettings(
            dailyReminder: UserDefaults.standard.bool(forKey: "notifications_dailyReminder"),
            streakReminder: UserDefaults.standard.bool(forKey: "notifications_streakReminder"),
            achievementUnlocked: UserDefaults.standard.bool(forKey: "notifications_achievementUnlocked"),
            moodCheckIn: UserDefaults.standard.bool(forKey: "notifications_moodCheckIn")
        )
    }

    private static func saveNotificationSettings(_ settings: NotificationSettings) {
        UserDefaults.standard.set(settings.dailyReminder, forKey: "notifications_dailyReminder")
        UserDefaults.standard.set(settings.streakReminder, forKey: "notifications_streakReminder")
        UserDefaults.standard.set(settings.achievementUnlocked, forKey: "notifications_achievementUnlocked")
        UserDefaults.standard.set(settings.moodCheckIn, forKey: "notifications_moodCheckIn")
    }

    private static func loadAppearanceSettings() -> AppearanceSettings {
        let themeRaw = UserDefaults.standard.string(forKey: "appearance_theme") ?? "system"
        let theme = AppearanceSettings.Theme(rawValue: themeRaw) ?? .system

        let fontSizeRaw = UserDefaults.standard.string(forKey: "appearance_fontSize") ?? "medium"
        let fontSize = AppearanceSettings.FontSize(rawValue: fontSizeRaw) ?? .medium

        let accentColor = UserDefaults.standard.string(forKey: "appearance_accentColor") ?? "blue"

        return AppearanceSettings(
            theme: theme,
            accentColor: accentColor,
            fontSize: fontSize
        )
    }

    private static func saveAppearanceSettings(_ settings: AppearanceSettings) {
        UserDefaults.standard.set(settings.theme.rawValue, forKey: "appearance_theme")
        UserDefaults.standard.set(settings.accentColor, forKey: "appearance_accentColor")
        UserDefaults.standard.set(settings.fontSize.rawValue, forKey: "appearance_fontSize")
    }
}

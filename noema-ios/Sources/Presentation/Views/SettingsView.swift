import SwiftUI

/// Settings view for app configuration
public struct SettingsView: View {
    @StateObject private var viewModel: SettingsViewModel
    @EnvironmentObject var appCoordinator: AppCoordinator

    public init() {
        _viewModel = StateObject(wrappedValue: SettingsViewModel(
            userProfileRepository: CoreDataUserProfileRepository(coreDataStack: .shared)
        ))
    }

    public var body: some View {
        List {
            // Profile section
            Section {
                HStack {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(viewModel.userProfile?.name ?? "Guest User")
                            .font(.headline)

                        Text("Level \(viewModel.userProfile?.level ?? 1)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 8)
            }

            // Notifications
            Section("Notifications") {
                Toggle("Daily Reminder", isOn: $viewModel.notificationSettings.dailyReminder)
                Toggle("Streak Reminder", isOn: $viewModel.notificationSettings.streakReminder)
                Toggle("Achievement Unlocked", isOn: $viewModel.notificationSettings.achievementUnlocked)
                Toggle("Mood Check-in", isOn: $viewModel.notificationSettings.moodCheckIn)
            }
            .onChange(of: viewModel.notificationSettings) { settings in
                viewModel.updateNotificationSettings(settings)
            }

            // Appearance
            Section("Appearance") {
                Picker("Theme", selection: $viewModel.appearanceSettings.theme) {
                    ForEach(AppearanceSettings.Theme.allCases, id: \.self) { theme in
                        Text(theme.displayName).tag(theme)
                    }
                }

                Picker("Font Size", selection: $viewModel.appearanceSettings.fontSize) {
                    ForEach(AppearanceSettings.FontSize.allCases, id: \.self) { size in
                        Text(size.displayName).tag(size)
                    }
                }
            }
            .onChange(of: viewModel.appearanceSettings) { settings in
                viewModel.updateAppearanceSettings(settings)
            }

            // Privacy
            Section {
                NavigationLink(destination: PrivacyDashboardView()) {
                    Label("Privacy & Security", systemImage: "lock.shield")
                }

                NavigationLink(destination: AIControlsView()) {
                    Label("AI Controls", systemImage: "sparkles")
                }
            }

            // About
            Section {
                Link(destination: URL(string: "https://noema.app/help")!) {
                    Label("Help & Support", systemImage: "questionmark.circle")
                }

                Link(destination: URL(string: "https://noema.app/privacy")!) {
                    Label("Privacy Policy", systemImage: "hand.raised")
                }

                Link(destination: URL(string: "https://noema.app/terms")!) {
                    Label("Terms of Service", systemImage: "doc.text")
                }

                HStack {
                    Text("Version")
                    Spacer()
                    Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                        .foregroundColor(.secondary)
                }
            }

            // Account
            Section {
                Button("Log Out") {
                    viewModel.confirmLogout()
                }
                .foregroundColor(.red)
            }
        }
        .navigationTitle("Settings")
        .task {
            await viewModel.loadSettings()
        }
        .alert("Log Out", isPresented: $viewModel.showingLogoutConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Log Out", role: .destructive) {
                viewModel.logout()
            }
        } message: {
            Text("Are you sure you want to log out?")
        }
    }
}

import SwiftUI

/// Main tab view that contains all primary app sections
public struct MainTabView: View {
    @EnvironmentObject var appCoordinator: AppCoordinator
    @State private var selectedTab: AppTab = .notes

    public var body: some View {
        TabView(selection: $selectedTab) {
            // Notes Tab
            NotesTabView()
                .tabItem {
                    Label(
                        AppTab.notes.title,
                        systemImage: selectedTab == .notes ?
                            AppTab.notes.selectedIcon : AppTab.notes.icon
                    )
                }
                .tag(AppTab.notes)

            // Mood Tab
            MoodTabView()
                .tabItem {
                    Label(
                        AppTab.mood.title,
                        systemImage: selectedTab == .mood ?
                            AppTab.mood.selectedIcon : AppTab.mood.icon
                    )
                }
                .tag(AppTab.mood)

            // Progress Tab
            ProgressTabView()
                .tabItem {
                    Label(
                        AppTab.progress.title,
                        systemImage: selectedTab == .progress ?
                            AppTab.progress.selectedIcon : AppTab.progress.icon
                    )
                }
                .tag(AppTab.progress)

            // Settings Tab
            SettingsTabView()
                .tabItem {
                    Label(
                        AppTab.settings.title,
                        systemImage: selectedTab == .settings ?
                            AppTab.settings.selectedIcon : AppTab.settings.icon
                    )
                }
                .tag(AppTab.settings)
        }
        .accentColor(.blue)
        .onChange(of: selectedTab) { newValue in
            appCoordinator.switchTab(newValue)
        }
        .onChange(of: appCoordinator.currentTab) { newValue in
            selectedTab = newValue
        }
    }
}

// MARK: - Tab Container Views

struct NotesTabView: View {
    @EnvironmentObject var appCoordinator: AppCoordinator

    var body: some View {
        NavigationStack(path: $appCoordinator.notesCoordinator!.navigationPath) {
            NoteListView()
                .navigationDestination(for: NavigationDestination.self) { destination in
                    destinationView(for: destination)
                }
        }
    }

    @ViewBuilder
    private func destinationView(for destination: NavigationDestination) -> some View {
        switch destination {
        case .noteDetail(let noteId):
            NoteDetailView(noteId: noteId)
        default:
            EmptyView()
        }
    }
}

struct MoodTabView: View {
    @EnvironmentObject var appCoordinator: AppCoordinator

    var body: some View {
        NavigationStack(path: $appCoordinator.moodCoordinator!.navigationPath) {
            MoodDashboardView()
                .navigationDestination(for: NavigationDestination.self) { destination in
                    destinationView(for: destination)
                }
        }
    }

    @ViewBuilder
    private func destinationView(for destination: NavigationDestination) -> some View {
        switch destination {
        case .moodTimeline:
            MoodTimelineView()
        default:
            EmptyView()
        }
    }
}

struct ProgressTabView: View {
    var body: some View {
        NavigationStack {
            ProgressView()
        }
    }
}

struct SettingsTabView: View {
    @EnvironmentObject var appCoordinator: AppCoordinator

    var body: some View {
        NavigationStack(path: $appCoordinator.settingsCoordinator!.navigationPath) {
            SettingsView()
                .navigationDestination(for: NavigationDestination.self) { destination in
                    destinationView(for: destination)
                }
        }
    }

    @ViewBuilder
    private func destinationView(for destination: NavigationDestination) -> some View {
        switch destination {
        case .privacyDashboard:
            PrivacyDashboardView()
        case .aiControls:
            AIControlsView()
        default:
            EmptyView()
        }
    }
}

// Placeholder Progress View
struct ProgressView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                LevelProgressView()
                AchievementListView()
                VirtualGardenView()
            }
            .padding()
        }
        .navigationTitle("Progress")
    }
}

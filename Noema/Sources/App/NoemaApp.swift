import SwiftUI
import CoreData

// MARK: - NoemaApp

@main
struct NoemaApp: App {

    // MARK: - Properties

    @StateObject private var persistenceController = PersistenceController.shared
    @StateObject private var appCoordinator = AppCoordinator()

    // MARK: - Scene

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.viewContext)
                .environmentObject(appCoordinator)
                .onAppear {
                    setupApp()
                }
        }
    }

    // MARK: - Setup

    private func setupApp() {
        // Initialize user profile if needed
        Task {
            await initializeUserProfile()
        }

        // Check CloudKit status
        Task {
            await checkCloudKitStatus()
        }

        // Request notifications permission
        Task {
            await requestNotificationPermission()
        }
    }

    private func initializeUserProfile() async {
        do {
            let profiles: [UserProfile] = try await persistenceController.fetch(
                entityName: "UserProfile",
                limit: 1
            )

            if profiles.isEmpty {
                // Create initial user profile
                try await persistenceController.performInBackground { context in
                    let profile = UserProfile(context: context)
                    profile.level = 1
                    profile.totalXP = 0
                    profile.currentStreak = 0
                    profile.subscriptionTier = .free

                    // Create system tags
                    for systemTag in SystemTag.allCases {
                        let tag = Tag(context: context)
                        tag.name = systemTag.rawValue
                        tag.color = systemTag.color
                        tag.icon = systemTag.icon
                        tag.isSystem = true
                    }

                    // Create default achievements
                    try await self.createDefaultAchievements(context: context)

                    try context.save()
                }

                print("✅ User profile initialized")
            }
        } catch {
            print("❌ Failed to initialize user profile: \(error)")
        }
    }

    private func createDefaultAchievements(context: NSManagedObjectContext) async throws {
        let achievementTypes: [AchievementType] = [
            .streak7Days, .streak30Days, .streak100Days, .streak365Days,
            .notes100, .notes500, .notes1000,
            .patternRecognized, .breakthrough, .emotionalBalance
        ]

        for type in achievementTypes {
            let achievement = Achievement(context: context)
            achievement.type = type
            achievement.title = type.rawValue.capitalized.replacingOccurrences(of: "_", with: " ")
            achievement.achievementDescription = "Unlock by achieving the goal"
            achievement.category = .consistency
            achievement.rarity = .common
            achievement.requiredValue = 1
            achievement.xpReward = 50
        }
    }

    private func checkCloudKitStatus() async {
        do {
            let status = try await SyncService.shared.checkCloudKitStatus()
            switch status {
            case .available:
                print("✅ CloudKit available")
            case .noAccount:
                print("⚠️ No iCloud account")
            case .restricted, .couldNotDetermine:
                print("❌ CloudKit unavailable")
            @unknown default:
                print("❓ Unknown CloudKit status")
            }
        } catch {
            print("❌ Failed to check CloudKit status: \(error)")
        }
    }

    private func requestNotificationPermission() async {
        // Request notification permission
        let center = UNUserNotificationCenter.current()
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            if granted {
                print("✅ Notifications authorized")
            } else {
                print("⚠️ Notifications denied")
            }
        } catch {
            print("❌ Failed to request notification permission: \(error)")
        }
    }
}

// MARK: - ContentView

struct ContentView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        TabView {
            NotesListView()
                .tabItem {
                    Label("Notes", systemImage: "note.text")
                }

            MoodDashboardView()
                .tabItem {
                    Label("Mood", systemImage: "heart.fill")
                }

            KnowledgeGraphView()
                .tabItem {
                    Label("Graph", systemImage: "network")
                }

            GamificationView()
                .tabItem {
                    Label("Progress", systemImage: "star.fill")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .accentColor(.blue)
    }
}

// MARK: - AppCoordinator

class AppCoordinator: ObservableObject {
    @Published var currentTab: Int = 0
    @Published var showingOnboarding: Bool = false

    func showNote(_ note: Note) {
        currentTab = 0
    }

    func showEntity(_ entity: Entity) {
        currentTab = 2
    }
}

// MARK: - Placeholder Views

struct NotesListView: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Note.createdAt, ascending: false)],
        predicate: NSPredicate(format: "isArchived == NO"),
        animation: .default)
    private var notes: FetchedResults<Note>

    var body: some View {
        NavigationView {
            List(notes) { note in
                VStack(alignment: .leading, spacing: 8) {
                    Text(note.content.firstWords(10))
                        .font(.headline)
                    Text(note.createdAt.smartFormatted)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Notes")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        // Create note
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
}

struct MoodDashboardView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Mood Dashboard")
                    .font(.largeTitle)
                Text("Track your emotional patterns")
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Mood")
        }
    }
}

struct KnowledgeGraphView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Knowledge Graph")
                    .font(.largeTitle)
                Text("Explore your connections")
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Graph")
        }
    }
}

struct GamificationView: View {
    @FetchRequest(
        sortDescriptors: [],
        animation: .default)
    private var profiles: FetchedResults<UserProfile>

    var profile: UserProfile? {
        profiles.first
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if let profile = profile {
                        // Level & XP
                        VStack {
                            Text("Level \(profile.level)")
                                .font(.largeTitle)
                                .bold()
                            Text("\(profile.totalXP) XP")
                                .foregroundColor(.secondary)
                        }
                        .padding()

                        // Streak
                        VStack {
                            Text("\(profile.currentStreak) Day Streak")
                                .font(.title2)
                            Text("Longest: \(profile.longestStreak) days")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)

                        // Stats
                        HStack(spacing: 20) {
                            StatView(title: "Notes", value: "\(profile.totalNotes)")
                            StatView(title: "Words", value: "\(profile.totalWords)")
                            StatView(title: "Entities", value: "\(profile.totalEntitiesDetected)")
                        }
                        .padding()
                    } else {
                        Text("Loading profile...")
                    }
                }
                .padding()
            }
            .navigationTitle("Progress")
        }
    }
}

struct StatView: View {
    let title: String
    let value: String

    var body: some View {
        VStack {
            Text(value)
                .font(.title)
                .bold()
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

struct SettingsView: View {
    var body: some View {
        NavigationView {
            List {
                Section("Account") {
                    NavigationLink("Profile") {
                        Text("Profile")
                    }
                    NavigationLink("Subscription") {
                        Text("Subscription")
                    }
                }

                Section("Privacy") {
                    NavigationLink("Privacy Dashboard") {
                        Text("Privacy Dashboard")
                    }
                    Toggle("CloudKit Sync", isOn: .constant(false))
                    Toggle("HealthKit Integration", isOn: .constant(false))
                }

                Section("About") {
                    NavigationLink("About Noema") {
                        Text("About")
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

// MARK: - String Extension (for views)

extension String {
    func firstWords(_ count: Int) -> String {
        let words = self.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
        return words.prefix(count).joined(separator: " ")
    }
}

// MARK: - UNUserNotificationCenter Import

import UserNotifications

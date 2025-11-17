import SwiftUI

@main
struct NoemaApp: App {
    // MARK: - Properties

    @StateObject private var appCoordinator = AppCoordinator()
    @StateObject private var appState = AppState()

    // MARK: - Initialization

    init() {
        setupAppearance()
        setupCoreData()
    }

    // MARK: - Body

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appCoordinator)
                .environmentObject(appState)
                .task {
                    await appCoordinator.start()
                }
        }
    }

    // MARK: - Setup

    private func setupAppearance() {
        // Configure global UI appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }

    private func setupCoreData() {
        // Initialize Core Data stack
        _ = CoreDataStack.shared
    }
}

// MARK: - App State

@MainActor
final class AppState: ObservableObject {
    @Published var isAuthenticated = false
    @Published var hasCompletedOnboarding = false
    @Published var currentUser: UserProfile?

    init() {
        // Load from UserDefaults
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        // Check authentication status
        checkAuthenticationStatus()
    }

    private func checkAuthenticationStatus() {
        // In production, check for valid session
        isAuthenticated = true // Simplified for now
    }
}

// MARK: - Content View

struct ContentView: View {
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var appState: AppState

    var body: some View {
        Group {
            if !appState.hasCompletedOnboarding {
                OnboardingView()
            } else if !appState.isAuthenticated {
                AuthenticationView()
            } else {
                MainTabView()
            }
        }
    }
}

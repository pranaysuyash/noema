import SwiftUI

/// Base protocol for all coordinators in the app
/// Coordinators handle navigation and flow logic, keeping it separate from ViewModels and Views
@MainActor
public protocol Coordinator: ObservableObject {
    /// The parent coordinator, if any
    var parent: (any Coordinator)? { get }

    /// Child coordinators managed by this coordinator
    var children: [any Coordinator] { get set }

    /// Start the coordinator's flow
    func start()

    /// Add a child coordinator
    func addChild(_ coordinator: any Coordinator)

    /// Remove a child coordinator
    func removeChild(_ coordinator: any Coordinator)
}

// MARK: - Default Implementations

extension Coordinator {
    public func addChild(_ coordinator: any Coordinator) {
        children.append(coordinator)
    }

    public func removeChild(_ coordinator: any Coordinator) {
        children.removeAll { child in
            ObjectIdentifier(child) == ObjectIdentifier(coordinator)
        }
    }
}

// MARK: - Navigation Destination

/// Represents all possible navigation destinations in the app
public enum NavigationDestination: Hashable, Identifiable {
    case noteDetail(noteId: UUID)
    case noteEditor(noteId: UUID? = nil)
    case voiceRecording
    case moodDashboard
    case moodTimeline
    case moodLog
    case achievements
    case achievementDetail(achievementId: String)
    case levelProgress
    case virtualGarden
    case settings
    case privacyDashboard
    case aiControls
    case onboarding
    case authentication

    public var id: String {
        switch self {
        case .noteDetail(let id):
            return "noteDetail-\(id)"
        case .noteEditor(let id):
            return "noteEditor-\(id?.uuidString ?? "new")"
        case .voiceRecording:
            return "voiceRecording"
        case .moodDashboard:
            return "moodDashboard"
        case .moodTimeline:
            return "moodTimeline"
        case .moodLog:
            return "moodLog"
        case .achievements:
            return "achievements"
        case .achievementDetail(let id):
            return "achievementDetail-\(id)"
        case .levelProgress:
            return "levelProgress"
        case .virtualGarden:
            return "virtualGarden"
        case .settings:
            return "settings"
        case .privacyDashboard:
            return "privacyDashboard"
        case .aiControls:
            return "aiControls"
        case .onboarding:
            return "onboarding"
        case .authentication:
            return "authentication"
        }
    }
}

// MARK: - Coordinator Error

public enum CoordinatorError: Error {
    case invalidTransition
    case missingDependency
    case childCoordinatorNotFound
}

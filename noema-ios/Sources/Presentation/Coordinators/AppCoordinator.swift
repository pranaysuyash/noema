import SwiftUI

/// Root coordinator that manages the overall app flow
/// Handles onboarding, authentication, and main tab navigation
@MainActor
public final class AppCoordinator: Coordinator {
    // MARK: - Coordinator Protocol

    public var parent: (any Coordinator)? = nil
    public var children: [any Coordinator] = []

    // MARK: - Published Properties

    @Published public var navigationPath = NavigationPath()
    @Published public var currentTab: AppTab = .notes
    @Published public var isPresentingSheet: Bool = false
    @Published public var sheetDestination: NavigationDestination?

    // MARK: - Child Coordinators

    public private(set) var notesCoordinator: NotesCoordinator?
    public private(set) var moodCoordinator: MoodCoordinator?
    public private(set) var settingsCoordinator: SettingsCoordinator?

    // MARK: - Dependencies

    private let noteRepository: NoteRepositoryProtocol
    private let moodRepository: MoodRepositoryProtocol
    private let achievementRepository: AchievementRepositoryProtocol
    private let userProfileRepository: UserProfileRepositoryProtocol
    private let tagRepository: TagRepositoryProtocol

    // MARK: - Initialization

    public init(
        noteRepository: NoteRepositoryProtocol,
        moodRepository: MoodRepositoryProtocol,
        achievementRepository: AchievementRepositoryProtocol,
        userProfileRepository: UserProfileRepositoryProtocol,
        tagRepository: TagRepositoryProtocol
    ) {
        self.noteRepository = noteRepository
        self.moodRepository = moodRepository
        self.achievementRepository = achievementRepository
        self.userProfileRepository = userProfileRepository
        self.tagRepository = tagRepository
    }

    // Convenience initializer with default repositories
    public convenience init() {
        let coreDataStack = CoreDataStack.shared
        self.init(
            noteRepository: CoreDataNoteRepository(coreDataStack: coreDataStack),
            moodRepository: CoreDataMoodRepository(coreDataStack: coreDataStack),
            achievementRepository: CoreDataAchievementRepository(coreDataStack: coreDataStack),
            userProfileRepository: CoreDataUserProfileRepository(coreDataStack: coreDataStack),
            tagRepository: CoreDataTagRepository(coreDataStack: coreDataStack)
        )
    }

    // MARK: - Coordinator Protocol

    public func start() {
        setupChildCoordinators()
    }

    // MARK: - Navigation

    public func navigate(to destination: NavigationDestination) {
        switch destination {
        case .noteDetail, .noteEditor, .voiceRecording:
            currentTab = .notes
            notesCoordinator?.navigate(to: destination)

        case .moodDashboard, .moodTimeline, .moodLog:
            currentTab = .mood
            moodCoordinator?.navigate(to: destination)

        case .achievements, .achievementDetail, .levelProgress, .virtualGarden:
            currentTab = .progress
            // Progress tab navigation handled inline

        case .settings, .privacyDashboard, .aiControls:
            currentTab = .settings
            settingsCoordinator?.navigate(to: destination)

        case .onboarding, .authentication:
            // These are handled at app level via AppState
            break
        }
    }

    public func presentSheet(_ destination: NavigationDestination) {
        sheetDestination = destination
        isPresentingSheet = true
    }

    public func dismissSheet() {
        isPresentingSheet = false
        sheetDestination = nil
    }

    public func switchTab(_ tab: AppTab) {
        currentTab = tab
    }

    // MARK: - Deep Linking

    public func handleDeepLink(_ url: URL) {
        // Parse deep link and navigate
        // Examples:
        // noema://note/123
        // noema://mood/timeline
        // noema://achievement/first_note

        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let host = components.host else {
            return
        }

        switch host {
        case "note":
            if let noteId = components.pathComponents.dropFirst().first,
               let uuid = UUID(uuidString: noteId) {
                navigate(to: .noteDetail(noteId: uuid))
            }

        case "mood":
            if components.path.contains("timeline") {
                navigate(to: .moodTimeline)
            } else {
                navigate(to: .moodDashboard)
            }

        case "achievement":
            if let achievementId = components.pathComponents.dropFirst().first {
                navigate(to: .achievementDetail(achievementId: achievementId))
            } else {
                navigate(to: .achievements)
            }

        default:
            break
        }
    }

    // MARK: - Push Notification Handling

    public func handleNotification(userInfo: [AnyHashable: Any]) {
        // Handle different notification types
        guard let type = userInfo["type"] as? String else { return }

        switch type {
        case "streak_reminder":
            switchTab(.notes)
            presentSheet(.noteEditor())

        case "mood_check_in":
            switchTab(.mood)
            navigate(to: .moodLog)

        case "achievement_unlocked":
            if let achievementId = userInfo["achievement_id"] as? String {
                switchTab(.progress)
                navigate(to: .achievementDetail(achievementId: achievementId))
            }

        case "crisis_resources":
            switchTab(.settings)
            navigate(to: .privacyDashboard)

        default:
            break
        }
    }

    // MARK: - Private Methods

    private func setupChildCoordinators() {
        // Notes Coordinator
        let notesCoord = NotesCoordinator(
            noteRepository: noteRepository,
            tagRepository: tagRepository,
            parent: self
        )
        addChild(notesCoord)
        self.notesCoordinator = notesCoord
        notesCoord.start()

        // Mood Coordinator
        let moodCoord = MoodCoordinator(
            moodRepository: moodRepository,
            noteRepository: noteRepository,
            parent: self
        )
        addChild(moodCoord)
        self.moodCoordinator = moodCoord
        moodCoord.start()

        // Settings Coordinator
        let settingsCoord = SettingsCoordinator(
            userProfileRepository: userProfileRepository,
            parent: self
        )
        addChild(settingsCoord)
        self.settingsCoordinator = settingsCoord
        settingsCoord.start()
    }
}

// MARK: - App Tab

public enum AppTab: String, CaseIterable, Identifiable {
    case notes
    case mood
    case progress
    case settings

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .notes:
            return "Notes"
        case .mood:
            return "Mood"
        case .progress:
            return "Progress"
        case .settings:
            return "Settings"
        }
    }

    public var icon: String {
        switch self {
        case .notes:
            return "note.text"
        case .mood:
            return "face.smiling"
        case .progress:
            return "chart.line.uptrend.xyaxis"
        case .settings:
            return "gearshape"
        }
    }

    public var selectedIcon: String {
        switch self {
        case .notes:
            return "note.text.badge.plus"
        case .mood:
            return "face.smiling.fill"
        case .progress:
            return "chart.line.uptrend.xyaxis.circle.fill"
        case .settings:
            return "gearshape.fill"
        }
    }
}

import SwiftUI

/// ViewModel for level progress screen
/// Shows user's current level, XP, and progression
@MainActor
public final class LevelProgressViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published public var userProfile: UserProfile?
    @Published public var isLoading: Bool = false
    @Published public var error: Error?
    @Published public var experienceHistory: [ExperienceEvent] = []
    @Published public var nextMilestones: [LevelMilestone] = []

    // MARK: - Computed Properties

    public var currentLevel: Int {
        userProfile?.level ?? 1
    }

    public var currentExperience: Int {
        userProfile?.experience ?? 0
    }

    public var experienceForNextLevel: Int {
        userProfile?.experienceForNextLevel ?? 100
    }

    public var progressToNextLevel: Double {
        guard experienceForNextLevel > 0 else { return 0.0 }
        return Double(currentExperience) / Double(experienceForNextLevel)
    }

    // MARK: - Dependencies

    private let userProfileRepository: UserProfileRepositoryProtocol

    // MARK: - Initialization

    public init(userProfileRepository: UserProfileRepositoryProtocol) {
        self.userProfileRepository = userProfileRepository
    }

    // MARK: - Public Methods

    public func loadProgress() async {
        isLoading = true
        error = nil

        do {
            userProfile = try await userProfileRepository.fetch()
            await loadExperienceHistory()
            generateNextMilestones()
        } catch {
            self.error = error
        }

        isLoading = false
    }

    public func refresh() async {
        await loadProgress()
    }

    // MARK: - Private Methods

    private func loadExperienceHistory() async {
        // TODO: Load actual experience history when implemented
        // For now, generate sample data
        experienceHistory = []
    }

    private func generateNextMilestones() {
        guard let profile = userProfile else { return }

        nextMilestones = [
            LevelMilestone(
                level: profile.level + 1,
                requiredExperience: profile.experienceForNextLevel,
                rewards: ["New theme color", "Advanced AI features"]
            ),
            LevelMilestone(
                level: profile.level + 5,
                requiredExperience: Int(100.0 * pow(Double(profile.level + 5), 1.5)),
                rewards: ["Premium export formats", "Extended mood history"]
            ),
            LevelMilestone(
                level: profile.level + 10,
                requiredExperience: Int(100.0 * pow(Double(profile.level + 10), 1.5)),
                rewards: ["Custom themes", "Priority support"]
            )
        ]
    }
}

// MARK: - Experience Event

public struct ExperienceEvent: Identifiable {
    public let id = UUID()
    public let date: Date
    public let amount: Int
    public let reason: String
    public let type: EventType

    public enum EventType {
        case noteCreated
        case streakMaintained
        case achievementUnlocked
        case moodLogged
    }
}

// MARK: - Level Milestone

public struct LevelMilestone: Identifiable {
    public let id = UUID()
    public let level: Int
    public let requiredExperience: Int
    public let rewards: [String]
}

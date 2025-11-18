import SwiftUI

/// ViewModel for achievement detail screen
/// Shows detailed information about a specific achievement
@MainActor
public final class AchievementDetailViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published public var achievement: Achievement?
    @Published public var relatedAchievements: [Achievement] = []
    @Published public var isLoading: Bool = false
    @Published public var error: Error?
    @Published public var showingShareSheet: Bool = false

    // MARK: - Dependencies

    private let achievementId: String
    private let achievementRepository: AchievementRepositoryProtocol

    // MARK: - Initialization

    public init(
        achievementId: String,
        achievementRepository: AchievementRepositoryProtocol
    ) {
        self.achievementId = achievementId
        self.achievementRepository = achievementRepository
    }

    // MARK: - Public Methods

    public func loadAchievement() async {
        isLoading = true
        error = nil

        do {
            achievement = try await achievementRepository.fetch(id: achievementId)

            if achievement == nil {
                error = AchievementDetailError.achievementNotFound
            } else {
                await loadRelatedAchievements()
            }
        } catch {
            self.error = error
        }

        isLoading = false
    }

    public func shareAchievement() {
        showingShareSheet = true
    }

    // MARK: - Private Methods

    private func loadRelatedAchievements() async {
        guard let currentAchievement = achievement else { return }

        do {
            let allAchievements = try await achievementRepository.fetchAll()

            // Find achievements of the same type or tier
            relatedAchievements = allAchievements.filter { achievement in
                achievement.id != achievementId &&
                (achievement.type == currentAchievement.type ||
                 achievement.tier == currentAchievement.tier)
            }.prefix(5).map { $0 }
        } catch {
            print("Failed to load related achievements: \(error)")
        }
    }
}

// MARK: - Achievement Detail Error

public enum AchievementDetailError: Error, LocalizedError {
    case achievementNotFound

    public var errorDescription: String? {
        switch self {
        case .achievementNotFound:
            return "Achievement not found"
        }
    }
}

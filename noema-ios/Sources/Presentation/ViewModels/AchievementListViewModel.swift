import SwiftUI

/// ViewModel for the achievements list screen
/// Shows all achievements with unlock status and progress
@MainActor
public final class AchievementListViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published public var achievements: [Achievement] = []
    @Published public var unlockedAchievements: [Achievement] = []
    @Published public var lockedAchievements: [Achievement] = []
    @Published public var isLoading: Bool = false
    @Published public var error: Error?
    @Published public var selectedFilter: AchievementFilter = .all
    @Published public var selectedTier: AchievementTier?

    // MARK: - Computed Properties

    public var totalAchievements: Int {
        achievements.count
    }

    public var unlockedCount: Int {
        achievements.filter { $0.isUnlocked }.count
    }

    public var completionPercentage: Double {
        guard totalAchievements > 0 else { return 0.0 }
        return Double(unlockedCount) / Double(totalAchievements) * 100.0
    }

    // MARK: - Dependencies

    private let achievementRepository: AchievementRepositoryProtocol

    // MARK: - Initialization

    public init(achievementRepository: AchievementRepositoryProtocol) {
        self.achievementRepository = achievementRepository
    }

    // MARK: - Public Methods

    public func loadAchievements() async {
        isLoading = true
        error = nil

        do {
            achievements = try await achievementRepository.fetchAll()
            filterAchievements()
        } catch {
            self.error = error
        }

        isLoading = false
    }

    public func refresh() async {
        await loadAchievements()
    }

    public func updateFilter(_ filter: AchievementFilter) {
        selectedFilter = filter
        filterAchievements()
    }

    public func updateTierFilter(_ tier: AchievementTier?) {
        selectedTier = tier
        filterAchievements()
    }

    // MARK: - Private Methods

    private func filterAchievements() {
        var filtered = achievements

        // Apply unlock status filter
        switch selectedFilter {
        case .all:
            break
        case .unlocked:
            filtered = filtered.filter { $0.isUnlocked }
        case .locked:
            filtered = filtered.filter { !$0.isUnlocked }
        case .inProgress:
            filtered = filtered.filter { !$0.isUnlocked && $0.progress > 0 }
        }

        // Apply tier filter
        if let tier = selectedTier {
            filtered = filtered.filter { $0.tier == tier }
        }

        // Separate and sort
        unlockedAchievements = filtered
            .filter { $0.isUnlocked }
            .sorted { ($0.unlockedAt ?? Date.distantPast) > ($1.unlockedAt ?? Date.distantPast) }

        lockedAchievements = filtered
            .filter { !$0.isUnlocked }
            .sorted { $0.progress > $1.progress }
    }
}

// MARK: - Achievement Filter

public enum AchievementFilter: String, CaseIterable, Identifiable {
    case all
    case unlocked
    case locked
    case inProgress

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .all: return "All"
        case .unlocked: return "Unlocked"
        case .locked: return "Locked"
        case .inProgress: return "In Progress"
        }
    }
}

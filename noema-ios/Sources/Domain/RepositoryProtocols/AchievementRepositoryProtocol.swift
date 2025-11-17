import Foundation

/// Repository protocol for Achievement entity operations
public protocol AchievementRepositoryProtocol: Sendable {
    // MARK: - CRUD Operations

    /// Save or update an achievement
    /// - Parameter achievement: The achievement to save
    /// - Returns: The saved achievement
    /// - Throws: RepositoryError if operation fails
    func save(_ achievement: Achievement) async throws -> Achievement

    /// Fetch an achievement by ID
    /// - Parameter id: The unique identifier
    /// - Returns: The achievement if found, nil otherwise
    /// - Throws: RepositoryError if operation fails
    func fetch(id: String) async throws -> Achievement?

    /// Fetch all achievements for the current user
    /// - Returns: Array of all achievements
    /// - Throws: RepositoryError if operation fails
    func fetchAll() async throws -> [Achievement]

    /// Update an existing achievement
    /// - Parameter achievement: The achievement with updated data
    /// - Returns: The updated achievement
    /// - Throws: RepositoryError if operation fails
    func update(_ achievement: Achievement) async throws -> Achievement

    // MARK: - Query Operations

    /// Fetch unlocked achievements
    /// - Returns: Array of achievements that have been unlocked
    /// - Throws: RepositoryError if operation fails
    func fetchUnlocked() async throws -> [Achievement]

    /// Fetch locked achievements
    /// - Returns: Array of achievements that haven't been unlocked yet
    /// - Throws: RepositoryError if operation fails
    func fetchLocked() async throws -> [Achievement]

    /// Fetch achievements by type
    /// - Parameter type: The achievement type to filter by
    /// - Returns: Array of matching achievements
    /// - Throws: RepositoryError if operation fails
    func fetchAchievements(ofType type: AchievementType) async throws -> [Achievement]

    /// Fetch achievements by tier
    /// - Parameter tier: The achievement tier to filter by
    /// - Returns: Array of matching achievements
    /// - Throws: RepositoryError if operation fails
    func fetchAchievements(ofTier tier: AchievementTier) async throws -> [Achievement]

    /// Fetch recently unlocked achievements
    /// - Parameter since: Date to fetch from
    /// - Returns: Array of recently unlocked achievements
    /// - Throws: RepositoryError if operation fails
    func fetchRecentlyUnlocked(since date: Date) async throws -> [Achievement]

    /// Fetch hidden achievements
    /// - Returns: Array of hidden achievements
    /// - Throws: RepositoryError if operation fails
    func fetchHidden() async throws -> [Achievement]

    /// Fetch achievements in progress (progress > 0 but not unlocked)
    /// - Returns: Array of in-progress achievements
    /// - Throws: RepositoryError if operation fails
    func fetchInProgress() async throws -> [Achievement]

    // MARK: - Statistics

    /// Count total achievements
    /// - Returns: Total number of achievements
    /// - Throws: RepositoryError if operation fails
    func countTotal() async throws -> Int

    /// Count unlocked achievements
    /// - Returns: Number of unlocked achievements
    /// - Throws: RepositoryError if operation fails
    func countUnlocked() async throws -> Int

    /// Calculate unlock percentage
    /// - Returns: Percentage of achievements unlocked (0.0 - 1.0)
    /// - Throws: RepositoryError if operation fails
    func unlockPercentage() async throws -> Float
}

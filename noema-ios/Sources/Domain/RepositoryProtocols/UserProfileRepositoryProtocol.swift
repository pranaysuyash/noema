import Foundation

/// Repository protocol for UserProfile entity operations
public protocol UserProfileRepositoryProtocol: Sendable {
    // MARK: - Profile Operations

    /// Fetch the current user's profile
    /// - Returns: The user profile
    /// - Throws: RepositoryError if operation fails or profile doesn't exist
    func fetchProfile() async throws -> UserProfile

    /// Save or update the user profile
    /// - Parameter profile: The profile to save
    /// - Returns: The saved profile
    /// - Throws: RepositoryError if operation fails
    func saveProfile(_ profile: UserProfile) async throws -> UserProfile

    /// Update specific profile fields
    /// - Parameter profile: The profile with updated data
    /// - Returns: The updated profile
    /// - Throws: RepositoryError if operation fails
    func updateProfile(_ profile: UserProfile) async throws -> UserProfile

    // MARK: - Gamification Operations

    /// Add experience points to profile
    /// - Parameters:
    ///   - points: Experience points to add
    ///   - checkLevelUp: Whether to check and process level-ups
    /// - Returns: Tuple of (updated profile, did level up)
    /// - Throws: RepositoryError if operation fails
    func addExperience(points: Int, checkLevelUp: Bool) async throws -> (UserProfile, Bool)

    /// Update streak based on current date
    /// - Returns: Updated profile with new streak
    /// - Throws: RepositoryError if operation fails
    func updateStreak() async throws -> UserProfile

    /// Increment note count
    /// - Returns: Updated profile
    /// - Throws: RepositoryError if operation fails
    func incrementNoteCount() async throws -> UserProfile

    /// Increment mood count
    /// - Returns: Updated profile
    /// - Throws: RepositoryError if operation fails
    func incrementMoodCount() async throws -> UserProfile

    // MARK: - Statistics

    /// Get user statistics summary
    /// - Returns: Dictionary of key statistics
    /// - Throws: RepositoryError if operation fails
    func getStatistics() async throws -> [String: Any]
}

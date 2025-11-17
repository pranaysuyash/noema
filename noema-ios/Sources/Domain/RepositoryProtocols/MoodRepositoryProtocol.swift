import Foundation

/// Repository protocol for MoodSnapshot entity operations
public protocol MoodRepositoryProtocol: Sendable {
    // MARK: - CRUD Operations

    /// Save a mood snapshot
    /// - Parameter mood: The mood snapshot to save
    /// - Returns: The saved mood snapshot
    /// - Throws: RepositoryError if operation fails
    func save(_ mood: MoodSnapshot) async throws -> MoodSnapshot

    /// Fetch a mood snapshot by ID
    /// - Parameter id: The unique identifier
    /// - Returns: The mood snapshot if found, nil otherwise
    /// - Throws: RepositoryError if operation fails
    func fetch(id: UUID) async throws -> MoodSnapshot?

    /// Fetch all mood snapshots for the current user
    /// - Returns: Array of all moods sorted by timestamp (newest first)
    /// - Throws: RepositoryError if operation fails
    func fetchAll() async throws -> [MoodSnapshot]

    /// Delete a mood snapshot
    /// - Parameter id: The unique identifier
    /// - Throws: RepositoryError if operation fails
    func delete(id: UUID) async throws

    // MARK: - Query Operations

    /// Fetch moods in a date range
    /// - Parameter dateRange: The date range to query
    /// - Returns: Array of moods in that range
    /// - Throws: RepositoryError if operation fails
    func fetchMoods(in dateRange: ClosedRange<Date>) async throws -> [MoodSnapshot]

    /// Fetch moods with a specific dominant emotion
    /// - Parameter emotion: The dominant emotion (e.g., "joy", "sadness")
    /// - Returns: Array of moods with that emotion
    /// - Throws: RepositoryError if operation fails
    func fetchMoods(withEmotion emotion: String) async throws -> [MoodSnapshot]

    /// Fetch moods by source (text, voice, manual)
    /// - Parameter source: The mood detection source
    /// - Returns: Array of moods from that source
    /// - Throws: RepositoryError if operation fails
    func fetchMoods(fromSource source: MoodSource) async throws -> [MoodSnapshot]

    /// Fetch recent moods
    /// - Parameter limit: Maximum number of moods to return
    /// - Returns: Array of recent moods
    /// - Throws: RepositoryError if operation fails
    func fetchRecent(limit: Int) async throws -> [MoodSnapshot]

    // MARK: - Analytics

    /// Calculate average emotional valence for a date range
    /// - Parameter dateRange: The date range to analyze
    /// - Returns: Average valence (-1 to 1)
    /// - Throws: RepositoryError if operation fails
    func averageValence(in dateRange: ClosedRange<Date>) async throws -> Float

    /// Calculate average emotional arousal for a date range
    /// - Parameter dateRange: The date range to analyze
    /// - Returns: Average arousal (0 to 1)
    /// - Throws: RepositoryError if operation fails
    func averageArousal(in dateRange: ClosedRange<Date>) async throws -> Float

    /// Get mood distribution by emotion type
    /// - Parameter dateRange: The date range to analyze
    /// - Returns: Dictionary mapping emotion names to counts
    /// - Throws: RepositoryError if operation fails
    func moodDistribution(in dateRange: ClosedRange<Date>) async throws -> [String: Int]

    /// Count total mood snapshots
    /// - Returns: Total number of moods
    /// - Throws: RepositoryError if operation fails
    func countMoods() async throws -> Int
}

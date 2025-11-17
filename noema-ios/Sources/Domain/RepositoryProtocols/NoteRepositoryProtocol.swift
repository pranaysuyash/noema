import Foundation

/// Repository protocol for Note entity operations
/// Defines the contract for data access without specifying implementation
public protocol NoteRepositoryProtocol: Sendable {
    // MARK: - CRUD Operations

    /// Create or update a note
    /// - Parameter note: The note to save
    /// - Returns: The saved note with updated metadata
    /// - Throws: RepositoryError if operation fails
    func save(_ note: Note) async throws -> Note

    /// Fetch a note by ID
    /// - Parameter id: The unique identifier
    /// - Returns: The note if found, nil otherwise
    /// - Throws: RepositoryError if operation fails
    func fetch(id: UUID) async throws -> Note?

    /// Fetch all notes for the current user
    /// - Returns: Array of all notes sorted by creation date (newest first)
    /// - Throws: RepositoryError if operation fails
    func fetchAll() async throws -> [Note]

    /// Fetch recent notes
    /// - Parameter limit: Maximum number of notes to return
    /// - Returns: Array of recent notes
    /// - Throws: RepositoryError if operation fails
    func fetchRecent(limit: Int) async throws -> [Note]

    /// Delete a note by ID
    /// - Parameter id: The unique identifier
    /// - Throws: RepositoryError if operation fails
    func delete(id: UUID) async throws

    /// Update an existing note
    /// - Parameter note: The note with updated data
    /// - Returns: The updated note
    /// - Throws: RepositoryError if operation fails
    func update(_ note: Note) async throws -> Note

    // MARK: - Query Operations

    /// Search notes by text content
    /// - Parameter query: Search query string
    /// - Returns: Array of matching notes
    /// - Throws: RepositoryError if operation fails
    func search(query: String) async throws -> [Note]

    /// Fetch notes with a specific dominant mood
    /// - Parameter mood: The dominant emotion (e.g., "joy", "sadness")
    /// - Returns: Array of notes with that mood
    /// - Throws: RepositoryError if operation fails
    func fetchNotes(withMood mood: String) async throws -> [Note]

    /// Fetch notes in a date range
    /// - Parameter dateRange: The date range to query
    /// - Returns: Array of notes in that range
    /// - Throws: RepositoryError if operation fails
    func fetchNotes(in dateRange: ClosedRange<Date>) async throws -> [Note]

    /// Fetch notes with specific tags
    /// - Parameter tags: Array of tags to filter by
    /// - Returns: Array of notes containing any of the tags
    /// - Throws: RepositoryError if operation fails
    func fetchNotes(withTags tags: [Tag]) async throws -> [Note]

    /// Fetch favorite notes
    /// - Returns: Array of favorited notes
    /// - Throws: RepositoryError if operation fails
    func fetchFavorites() async throws -> [Note]

    /// Fetch archived notes
    /// - Returns: Array of archived notes
    /// - Throws: RepositoryError if operation fails
    func fetchArchived() async throws -> [Note]

    // MARK: - Statistics

    /// Count total notes
    /// - Returns: Total number of notes
    /// - Throws: RepositoryError if operation fails
    func countNotes() async throws -> Int

    /// Count notes in date range
    /// - Parameter dateRange: The date range to query
    /// - Returns: Number of notes in range
    /// - Throws: RepositoryError if operation fails
    func countNotes(in dateRange: ClosedRange<Date>) async throws -> Int
}

// MARK: - Repository Errors

public enum RepositoryError: Error, LocalizedError {
    case notFound
    case saveFailed(underlying: Error)
    case fetchFailed(underlying: Error)
    case deleteFailed(underlying: Error)
    case invalidData
    case unauthorized

    public var errorDescription: String? {
        switch self {
        case .notFound:
            return "The requested item was not found"
        case .saveFailed(let error):
            return "Failed to save: \(error.localizedDescription)"
        case .fetchFailed(let error):
            return "Failed to fetch: \(error.localizedDescription)"
        case .deleteFailed(let error):
            return "Failed to delete: \(error.localizedDescription)"
        case .invalidData:
            return "The data is invalid or corrupted"
        case .unauthorized:
            return "You are not authorized to perform this operation"
        }
    }
}

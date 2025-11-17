import Foundation

/// Repository protocol for Tag entity operations
public protocol TagRepositoryProtocol: Sendable {
    // MARK: - CRUD Operations

    /// Create a new tag
    /// - Parameter tag: The tag to create
    /// - Returns: The created tag
    /// - Throws: RepositoryError if tag with same name already exists or operation fails
    func create(_ tag: Tag) async throws -> Tag

    /// Fetch a tag by ID
    /// - Parameter id: The unique identifier
    /// - Returns: The tag if found, nil otherwise
    /// - Throws: RepositoryError if operation fails
    func fetch(id: UUID) async throws -> Tag?

    /// Fetch a tag by name
    /// - Parameter name: The tag name (case-insensitive)
    /// - Returns: The tag if found, nil otherwise
    /// - Throws: RepositoryError if operation fails
    func fetch(name: String) async throws -> Tag?

    /// Fetch all tags for the current user
    /// - Returns: Array of all tags
    /// - Throws: RepositoryError if operation fails
    func fetchAll() async throws -> [Tag]

    /// Update a tag
    /// - Parameter tag: The tag with updated data
    /// - Returns: The updated tag
    /// - Throws: RepositoryError if operation fails
    func update(_ tag: Tag) async throws -> Tag

    /// Delete a tag
    /// - Parameter id: The unique identifier
    /// - Throws: RepositoryError if operation fails
    func delete(id: UUID) async throws

    // MARK: - Query Operations

    /// Fetch popular tags sorted by usage count
    /// - Parameter limit: Maximum number of tags to return
    /// - Returns: Array of most frequently used tags
    /// - Throws: RepositoryError if operation fails
    func fetchPopular(limit: Int) async throws -> [Tag]

    /// Fetch recently created tags
    /// - Parameter limit: Maximum number of tags to return
    /// - Returns: Array of recently created tags
    /// - Throws: RepositoryError if operation fails
    func fetchRecent(limit: Int) async throws -> [Tag]

    /// Search tags by name
    /// - Parameter query: Search query string
    /// - Returns: Array of matching tags
    /// - Throws: RepositoryError if operation fails
    func search(query: String) async throws -> [Tag]

    /// Fetch frequently used tags (usage count >= threshold)
    /// - Parameter threshold: Minimum usage count
    /// - Returns: Array of frequently used tags
    /// - Throws: RepositoryError if operation fails
    func fetchFrequentlyUsed(threshold: Int) async throws -> [Tag]

    // MARK: - Tag Operations

    /// Increment usage count for a tag
    /// - Parameter id: The tag identifier
    /// - Returns: Updated tag
    /// - Throws: RepositoryError if operation fails
    func incrementUsage(id: UUID) async throws -> Tag

    /// Decrement usage count for a tag
    /// - Parameter id: The tag identifier
    /// - Returns: Updated tag
    /// - Throws: RepositoryError if operation fails
    func decrementUsage(id: UUID) async throws -> Tag

    /// Get or create a tag by name
    /// - Parameters:
    ///   - name: The tag name
    ///   - colorHex: Optional color hex for new tags
    /// - Returns: Existing or newly created tag
    /// - Throws: RepositoryError if operation fails
    func getOrCreate(name: String, colorHex: String?) async throws -> Tag

    // MARK: - Statistics

    /// Count total tags
    /// - Returns: Total number of tags
    /// - Throws: RepositoryError if operation fails
    func countTags() async throws -> Int

    /// Get tag usage statistics
    /// - Returns: Dictionary mapping tag IDs to usage counts
    /// - Throws: RepositoryError if operation fails
    func usageStatistics() async throws -> [UUID: Int]
}

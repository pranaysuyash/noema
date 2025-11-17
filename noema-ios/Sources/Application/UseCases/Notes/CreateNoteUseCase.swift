import Foundation

/// Use case for creating a new note with AI analysis
public protocol CreateNoteUseCase: Sendable {
    /// Execute the use case to create a note
    /// - Parameter note: The note to create
    /// - Returns: The created note with AI-generated metadata
    /// - Throws: Error if creation fails
    func execute(note: Note) async throws -> Note
}

/// Default implementation of CreateNoteUseCase
public actor DefaultCreateNoteUseCase: CreateNoteUseCase {
    // MARK: - Dependencies

    private let noteRepository: NoteRepositoryProtocol
    private let userProfileRepository: UserProfileRepositoryProtocol

    // MARK: - Initialization

    public init(
        noteRepository: NoteRepositoryProtocol,
        userProfileRepository: UserProfileRepositoryProtocol
    ) {
        self.noteRepository = noteRepository
        self.userProfileRepository = userProfileRepository
    }

    // MARK: - Execution

    public func execute(note: Note) async throws -> Note {
        var finalNote = note

        // 1. Validate note content
        guard !note.content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw NoteError.emptyContent
        }

        // 2. Save note to repository
        finalNote = try await noteRepository.save(finalNote)

        // 3. Update user statistics (fire and forget)
        Task.detached { [userProfileRepository] in
            try? await userProfileRepository.incrementNoteCount()
            try? await userProfileRepository.updateStreak()
        }

        return finalNote
    }
}

// MARK: - Errors

public enum NoteError: Error, LocalizedError {
    case emptyContent
    case invalidNote
    case aiProcessingFailed(underlying: Error)

    public var errorDescription: String? {
        switch self {
        case .emptyContent:
            return "Note content cannot be empty"
        case .invalidNote:
            return "Note data is invalid"
        case .aiProcessingFailed(let error):
            return "AI processing failed: \(error.localizedDescription)"
        }
    }
}

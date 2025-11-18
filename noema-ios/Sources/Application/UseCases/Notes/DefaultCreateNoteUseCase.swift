import Foundation

/// Default implementation of CreateNoteUseCase
public actor DefaultCreateNoteUseCase: CreateNoteUseCase {
    // MARK: - Properties

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

    // MARK: - Execute

    public func execute(note: Note) async throws -> Note {
        // Validate note
        guard !note.content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw NoteError.emptyContent
        }

        // Save note
        let savedNote = try await noteRepository.save(note)

        // Update user stats asynchronously
        Task.detached {
            try? await self.userProfileRepository.incrementNoteCount()
            try? await self.userProfileRepository.updateStreak()
            try? await self.userProfileRepository.addExperience(10) // 10 XP per note
        }

        return savedNote
    }
}

// MARK: - Note Error

public enum NoteError: Error, LocalizedError {
    case emptyContent
    case saveFailed
    case invalidData

    public var errorDescription: String? {
        switch self {
        case .emptyContent:
            return "Note content cannot be empty"
        case .saveFailed:
            return "Failed to save note"
        case .invalidData:
            return "Invalid note data"
        }
    }
}

import SwiftUI

/// ViewModel for the note detail screen
/// Displays full note content with mood, tags, and metadata
@MainActor
public final class NoteDetailViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published public var note: Note?
    @Published public var isLoading: Bool = false
    @Published public var error: Error?
    @Published public var relatedNotes: [Note] = []
    @Published public var showingDeleteConfirmation: Bool = false
    @Published public var showingShareSheet: Bool = false

    // MARK: - Dependencies

    private let noteId: UUID
    private let noteRepository: NoteRepositoryProtocol

    // MARK: - Initialization

    public init(
        noteId: UUID,
        noteRepository: NoteRepositoryProtocol
    ) {
        self.noteId = noteId
        self.noteRepository = noteRepository
    }

    // MARK: - Public Methods

    public func loadNote() async {
        isLoading = true
        error = nil

        do {
            note = try await noteRepository.fetch(id: noteId)

            if note == nil {
                error = NoteDetailError.noteNotFound
            } else {
                await loadRelatedNotes()
            }
        } catch {
            self.error = error
        }

        isLoading = false
    }

    public func toggleFavorite() async {
        guard var currentNote = note else { return }

        currentNote.isFavorite.toggle()

        do {
            note = try await noteRepository.update(currentNote)
        } catch {
            self.error = error
        }
    }

    public func archiveNote() async {
        guard var currentNote = note else { return }

        currentNote.isArchived.toggle()

        do {
            note = try await noteRepository.update(currentNote)
        } catch {
            self.error = error
        }
    }

    public func deleteNote() async throws {
        try await noteRepository.delete(id: noteId)
    }

    public func shareNote() {
        showingShareSheet = true
    }

    public func confirmDelete() {
        showingDeleteConfirmation = true
    }

    // MARK: - Private Methods

    private func loadRelatedNotes() async {
        guard let currentNote = note else { return }

        do {
            // Find notes with similar tags
            if !currentNote.tags.isEmpty {
                let tagRelatedNotes = try await noteRepository.fetchNotes(withTags: currentNote.tags)
                relatedNotes = Array(tagRelatedNotes.filter { $0.id != noteId }.prefix(5))
            }

            // If no tag matches, find notes with similar mood
            if relatedNotes.isEmpty, let mood = currentNote.mood {
                let moodRelatedNotes = try await noteRepository.fetchNotes(withMood: mood.dimensions.dominantEmotion)
                relatedNotes = Array(moodRelatedNotes.filter { $0.id != noteId }.prefix(5))
            }
        } catch {
            // Silently fail for related notes
            print("Failed to load related notes: \(error)")
        }
    }
}

// MARK: - Note Detail Error

public enum NoteDetailError: Error, LocalizedError {
    case noteNotFound
    case updateFailed
    case deleteFailed

    public var errorDescription: String? {
        switch self {
        case .noteNotFound:
            return "Note not found"
        case .updateFailed:
            return "Failed to update note"
        case .deleteFailed:
            return "Failed to delete note"
        }
    }
}

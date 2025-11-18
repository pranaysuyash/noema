import SwiftUI

/// Coordinator for note-related flows
/// Manages navigation between note list, editor, detail, voice recording, and search
@MainActor
public final class NotesCoordinator: Coordinator {
    // MARK: - Coordinator Protocol

    public var parent: (any Coordinator)?
    public var children: [any Coordinator] = []

    // MARK: - Published Properties

    @Published public var navigationPath = NavigationPath()
    @Published public var isPresentingEditor: Bool = false
    @Published public var isPresentingVoiceRecorder: Bool = false
    @Published public var isPresentingFilters: Bool = false
    @Published public var selectedNoteId: UUID?
    @Published public var editingNoteId: UUID?

    // MARK: - Dependencies

    private let noteRepository: NoteRepositoryProtocol
    private let tagRepository: TagRepositoryProtocol

    // MARK: - Initialization

    public init(
        noteRepository: NoteRepositoryProtocol,
        tagRepository: TagRepositoryProtocol,
        parent: (any Coordinator)? = nil
    ) {
        self.noteRepository = noteRepository
        self.tagRepository = tagRepository
        self.parent = parent
    }

    // MARK: - Coordinator Protocol

    public func start() {
        // Initial setup for notes flow
        // Could pre-load recent notes, check for drafts, etc.
    }

    // MARK: - Navigation

    public func navigate(to destination: NavigationDestination) {
        switch destination {
        case .noteDetail(let noteId):
            showNoteDetail(noteId: noteId)

        case .noteEditor(let noteId):
            showNoteEditor(noteId: noteId)

        case .voiceRecording:
            showVoiceRecorder()

        default:
            break
        }
    }

    public func showNoteDetail(noteId: UUID) {
        selectedNoteId = noteId
        navigationPath.append(NavigationDestination.noteDetail(noteId: noteId))
    }

    public func showNoteEditor(noteId: UUID? = nil) {
        editingNoteId = noteId
        isPresentingEditor = true
    }

    public func showVoiceRecorder() {
        isPresentingVoiceRecorder = true
    }

    public func showFilters() {
        isPresentingFilters = true
    }

    public func dismissEditor() {
        isPresentingEditor = false
        editingNoteId = nil
    }

    public func dismissVoiceRecorder() {
        isPresentingVoiceRecorder = false
    }

    public func dismissFilters() {
        isPresentingFilters = false
    }

    public func popToRoot() {
        navigationPath.removeLast(navigationPath.count)
        selectedNoteId = nil
    }

    // MARK: - Note Actions

    public func createNewNote() {
        showNoteEditor(noteId: nil)
    }

    public func editNote(_ noteId: UUID) {
        showNoteEditor(noteId: noteId)
    }

    public func viewNote(_ noteId: UUID) {
        showNoteDetail(noteId: noteId)
    }

    public func deleteNote(_ noteId: UUID) async throws {
        try await noteRepository.delete(id: noteId)

        // If we're viewing the deleted note, pop back
        if selectedNoteId == noteId {
            navigationPath.removeLast()
            selectedNoteId = nil
        }
    }

    public func duplicateNote(_ noteId: UUID) async throws {
        guard let originalNote = try await noteRepository.fetch(id: noteId) else {
            throw CoordinatorError.missingDependency
        }

        // Create a copy with new ID and timestamps
        let duplicatedNote = Note(
            id: UUID(),
            content: originalNote.content,
            createdAt: Date(),
            modifiedAt: Date(),
            mood: originalNote.mood,
            entities: originalNote.entities,
            summary: originalNote.summary,
            tags: originalNote.tags,
            isFavorite: false,
            isArchived: false
        )

        _ = try await noteRepository.save(duplicatedNote)

        // Navigate to the new note
        showNoteEditor(noteId: duplicatedNote.id)
    }

    public func shareNote(_ noteId: UUID) async throws -> URL {
        guard let note = try await noteRepository.fetch(id: noteId) else {
            throw CoordinatorError.missingDependency
        }

        // Create temporary markdown file for sharing
        let fileName = "note-\(note.id.uuidString).md"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        var markdown = "# Note\n\n"
        markdown += "**Created:** \(note.createdAt.formatted())\n\n"

        if let mood = note.mood {
            markdown += "**Mood:** \(mood.dimensions.dominantEmotion)\n\n"
        }

        if !note.tags.isEmpty {
            markdown += "**Tags:** \(note.tags.map { $0.name }.joined(separator: ", "))\n\n"
        }

        markdown += "---\n\n"
        markdown += note.content

        try markdown.write(to: tempURL, atomically: true, encoding: .utf8)

        return tempURL
    }

    // MARK: - Search

    public func search(query: String) async throws -> [Note] {
        guard !query.isEmpty else {
            return try await noteRepository.fetchAll()
        }

        return try await noteRepository.search(query: query)
    }

    // MARK: - Filters

    public func applyFilter(_ filter: NoteFilter) async throws -> [Note] {
        switch filter {
        case .all:
            return try await noteRepository.fetchAll()

        case .favorites:
            return try await noteRepository.fetchFavorites()

        case .archived:
            return try await noteRepository.fetchArchived()

        case .byTag(let tag):
            return try await noteRepository.fetchNotes(withTags: [tag])

        case .byMood(let mood):
            return try await noteRepository.fetchNotes(withMood: mood)

        case .byDateRange(let range):
            return try await noteRepository.fetchNotes(in: range)
        }
    }
}

// MARK: - Note Filter

public enum NoteFilter: Hashable {
    case all
    case favorites
    case archived
    case byTag(Tag)
    case byMood(String)
    case byDateRange(ClosedRange<Date>)
}

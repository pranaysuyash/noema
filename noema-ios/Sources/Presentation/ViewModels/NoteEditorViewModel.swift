import SwiftUI
import Combine

/// ViewModel for the note editor screen
/// Handles note creation, editing, auto-save, and AI processing
@MainActor
public final class NoteEditorViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published public var content: String = ""
    @Published public var selectedTags: [Tag] = []
    @Published public var detectedMood: MoodSnapshot?
    @Published public var summary: String?
    @Published public var entities: [NamedEntity] = []
    @Published public var isSaving: Bool = false
    @Published public var isProcessingAI: Bool = false
    @Published public var error: Error?
    @Published public var hasUnsavedChanges: Bool = false
    @Published public var wordCount: Int = 0
    @Published public var characterCount: Int = 0
    @Published public var estimatedReadingTime: TimeInterval = 0

    // MARK: - Private Properties

    private var noteId: UUID?
    private var originalNote: Note?
    private var autoSaveTimer: Timer?
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Dependencies

    private let noteRepository: NoteRepositoryProtocol
    private let tagRepository: TagRepositoryProtocol
    private let createNoteUseCase: CreateNoteUseCase
    private let analyzeMoodUseCase: AnalyzeMoodUseCase

    // MARK: - Initialization

    public init(
        noteId: UUID? = nil,
        noteRepository: NoteRepositoryProtocol,
        tagRepository: TagRepositoryProtocol,
        createNoteUseCase: CreateNoteUseCase,
        analyzeMoodUseCase: AnalyzeMoodUseCase
    ) {
        self.noteId = noteId
        self.noteRepository = noteRepository
        self.tagRepository = tagRepository
        self.createNoteUseCase = createNoteUseCase
        self.analyzeMoodUseCase = analyzeMoodUseCase

        setupContentObservers()
        setupAutoSave()
    }

    deinit {
        autoSaveTimer?.invalidate()
    }

    // MARK: - Public Methods

    public func loadNote() async {
        guard let noteId = noteId else { return }

        do {
            guard let note = try await noteRepository.fetch(id: noteId) else {
                error = NoteEditorError.noteNotFound
                return
            }

            originalNote = note
            content = note.content
            selectedTags = note.tags
            detectedMood = note.mood
            summary = note.summary
            entities = note.entities
            hasUnsavedChanges = false
        } catch {
            self.error = error
        }
    }

    public func save() async {
        guard !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            error = NoteEditorError.emptyContent
            return
        }

        isSaving = true
        error = nil

        do {
            let note = Note(
                id: noteId ?? UUID(),
                content: content,
                createdAt: originalNote?.createdAt ?? Date(),
                modifiedAt: Date(),
                mood: detectedMood,
                entities: entities,
                summary: summary,
                tags: selectedTags,
                isFavorite: originalNote?.isFavorite ?? false,
                isArchived: originalNote?.isArchived ?? false
            )

            if originalNote != nil {
                _ = try await noteRepository.update(note)
            } else {
                _ = try await createNoteUseCase.execute(note: note)
            }

            hasUnsavedChanges = false
        } catch {
            self.error = error
        }

        isSaving = false
    }

    public func analyzeContent() async {
        guard !content.isEmpty else { return }

        isProcessingAI = true

        do {
            // Analyze mood from text
            let mood = try await analyzeMoodUseCase.execute(text: content)
            detectedMood = mood

            // TODO: Extract entities and generate summary
            // This would call additional use cases when implemented

        } catch {
            self.error = error
        }

        isProcessingAI = false
    }

    public func addTag(_ tag: Tag) {
        if !selectedTags.contains(where: { $0.id == tag.id }) {
            selectedTags.append(tag)
            hasUnsavedChanges = true
        }
    }

    public func removeTag(_ tag: Tag) {
        selectedTags.removeAll { $0.id == tag.id }
        hasUnsavedChanges = true
    }

    public func overrideMood(_ mood: MoodSnapshot) {
        detectedMood = mood
        hasUnsavedChanges = true
    }

    public func clearMood() {
        detectedMood = nil
        hasUnsavedChanges = true
    }

    public func discardChanges() {
        if let originalNote = originalNote {
            content = originalNote.content
            selectedTags = originalNote.tags
            detectedMood = originalNote.mood
            summary = originalNote.summary
            entities = originalNote.entities
        } else {
            content = ""
            selectedTags = []
            detectedMood = nil
            summary = nil
            entities = []
        }
        hasUnsavedChanges = false
    }

    // MARK: - Private Methods

    private func setupContentObservers() {
        $content
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .sink { [weak self] newContent in
                self?.updateContentMetrics(newContent)
                self?.hasUnsavedChanges = true
            }
            .store(in: &cancellables)
    }

    private func setupAutoSave() {
        autoSaveTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self = self, self.hasUnsavedChanges else { return }
                await self.save()
            }
        }
    }

    private func updateContentMetrics(_ text: String) {
        wordCount = text.split(separator: " ").count
        characterCount = text.count
        estimatedReadingTime = Double(wordCount) / 200.0 * 60.0  // seconds
    }
}

// MARK: - Note Editor Error

public enum NoteEditorError: Error, LocalizedError {
    case emptyContent
    case noteNotFound
    case saveFailed
    case aiProcessingFailed

    public var errorDescription: String? {
        switch self {
        case .emptyContent:
            return "Cannot save an empty note"
        case .noteNotFound:
            return "Note not found"
        case .saveFailed:
            return "Failed to save note"
        case .aiProcessingFailed:
            return "AI processing failed"
        }
    }
}

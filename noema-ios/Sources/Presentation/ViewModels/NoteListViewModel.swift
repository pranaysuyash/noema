import SwiftUI
import Combine

/// ViewModel for the note list screen
/// Manages note fetching, filtering, sorting, and search
@MainActor
public final class NoteListViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published public var notes: [Note] = []
    @Published public var filteredNotes: [Note] = []
    @Published public var isLoading: Bool = false
    @Published public var error: Error?
    @Published public var searchQuery: String = ""
    @Published public var selectedFilter: NoteFilter = .all
    @Published public var sortOrder: SortOrder = .modifiedDate
    @Published public var viewMode: ViewMode = .list

    // MARK: - Dependencies

    private let noteRepository: NoteRepositoryProtocol
    private let tagRepository: TagRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    public init(
        noteRepository: NoteRepositoryProtocol,
        tagRepository: TagRepositoryProtocol
    ) {
        self.noteRepository = noteRepository
        self.tagRepository = tagRepository
        setupSearchDebounce()
    }

    // MARK: - Public Methods

    public func loadNotes() async {
        isLoading = true
        error = nil

        do {
            notes = try await noteRepository.fetchAll()
            applyFiltersAndSort()
        } catch {
            self.error = error
        }

        isLoading = false
    }

    public func refresh() async {
        await loadNotes()
    }

    public func deleteNote(_ note: Note) async {
        do {
            try await noteRepository.delete(id: note.id)
            notes.removeAll { $0.id == note.id }
            applyFiltersAndSort()
        } catch {
            self.error = error
        }
    }

    public func toggleFavorite(_ note: Note) async {
        var updatedNote = note
        updatedNote.isFavorite.toggle()

        do {
            _ = try await noteRepository.update(updatedNote)
            if let index = notes.firstIndex(where: { $0.id == note.id }) {
                notes[index] = updatedNote
                applyFiltersAndSort()
            }
        } catch {
            self.error = error
        }
    }

    public func archiveNote(_ note: Note) async {
        var updatedNote = note
        updatedNote.isArchived.toggle()

        do {
            _ = try await noteRepository.update(updatedNote)
            if let index = notes.firstIndex(where: { $0.id == note.id }) {
                notes[index] = updatedNote
                applyFiltersAndSort()
            }
        } catch {
            self.error = error
        }
    }

    public func updateFilter(_ filter: NoteFilter) {
        selectedFilter = filter
        applyFiltersAndSort()
    }

    public func updateSortOrder(_ order: SortOrder) {
        sortOrder = order
        applyFiltersAndSort()
    }

    public func updateViewMode(_ mode: ViewMode) {
        viewMode = mode
    }

    // MARK: - Private Methods

    private func setupSearchDebounce() {
        $searchQuery
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.applyFiltersAndSort()
            }
            .store(in: &cancellables)
    }

    private func applyFiltersAndSort() {
        var result = notes

        // Apply search filter
        if !searchQuery.isEmpty {
            result = result.filter { note in
                note.content.localizedCaseInsensitiveContains(searchQuery) ||
                note.summary?.localizedCaseInsensitiveContains(searchQuery) == true ||
                note.tags.contains { $0.name.localizedCaseInsensitiveContains(searchQuery) }
            }
        }

        // Apply selected filter
        switch selectedFilter {
        case .all:
            result = result.filter { !$0.isArchived }

        case .favorites:
            result = result.filter { $0.isFavorite && !$0.isArchived }

        case .archived:
            result = result.filter { $0.isArchived }

        case .byTag(let tag):
            result = result.filter { note in
                note.tags.contains { $0.id == tag.id } && !note.isArchived
            }

        case .byMood(let mood):
            result = result.filter { note in
                note.mood?.dimensions.dominantEmotion == mood && !note.isArchived
            }

        case .byDateRange(let range):
            result = result.filter { note in
                range.contains(note.createdAt) && !note.isArchived
            }
        }

        // Apply sort order
        switch sortOrder {
        case .createdDate:
            result.sort { $0.createdAt > $1.createdAt }

        case .modifiedDate:
            result.sort { $0.modifiedAt > $1.modifiedAt }

        case .title:
            result.sort { note1, note2 in
                let title1 = note1.content.prefix(50).lowercased()
                let title2 = note2.content.prefix(50).lowercased()
                return title1 < title2
            }

        case .mood:
            result.sort { note1, note2 in
                let valence1 = note1.mood?.dimensions.valence ?? 0
                let valence2 = note2.mood?.dimensions.valence ?? 0
                return valence1 > valence2
            }
        }

        filteredNotes = result
    }
}

// MARK: - Sort Order

public enum SortOrder: String, CaseIterable, Identifiable {
    case createdDate
    case modifiedDate
    case title
    case mood

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .createdDate: return "Date Created"
        case .modifiedDate: return "Date Modified"
        case .title: return "Title"
        case .mood: return "Mood"
        }
    }

    public var icon: String {
        switch self {
        case .createdDate: return "calendar.badge.plus"
        case .modifiedDate: return "calendar.badge.clock"
        case .title: return "textformat"
        case .mood: return "face.smiling"
        }
    }
}

// MARK: - View Mode

public enum ViewMode: String, CaseIterable, Identifiable {
    case list
    case grid
    case compact

    public var id: String { rawValue }

    public var icon: String {
        switch self {
        case .list: return "list.bullet"
        case .grid: return "square.grid.2x2"
        case .compact: return "list.dash"
        }
    }
}

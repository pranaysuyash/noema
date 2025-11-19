//
//  NoteListViewModel.swift
//  Noema
//
//  Created on January 18, 2025.
//

import Foundation
import CoreData
import Combine

@MainActor
public final class NoteListViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published public var notes: [Note] = []
    @Published public var searchText: String = ""
    @Published public var selectedFilter: FilterOption = .all
    @Published public var selectedSortOption: SortOption = .dateDescending
    @Published public var isLoading: Bool = false
    @Published public var error: Error?

    // MARK: - Filter & Sort Options

    public enum FilterOption: String, CaseIterable {
        case all = "All"
        case favorites = "Favorites"
        case today = "Today"
        case thisWeek = "This Week"
        case withAudio = "With Audio"
        case withEmotion = "With Emotion"
    }

    public enum SortOption: String, CaseIterable {
        case dateDescending = "Newest First"
        case dateAscending = "Oldest First"
        case titleAscending = "Title A-Z"
        case qualityScore = "Quality Score"
    }

    // MARK: - Dependencies

    private let noteService: NoteService
    private let persistenceController: PersistenceController
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    public init(
        noteService: NoteService = NoteService(),
        persistenceController: PersistenceController = .shared
    ) {
        self.noteService = noteService
        self.persistenceController = persistenceController

        setupBindings()
    }

    // MARK: - Setup

    private func setupBindings() {
        // Re-fetch notes when search text or filters change
        Publishers.CombineLatest3($searchText, $selectedFilter, $selectedSortOption)
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] _, _, _ in
                Task { await self?.fetchNotes() }
            }
            .store(in: &cancellables)
    }

    // MARK: - Public Methods

    public func fetchNotes() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let filters = buildFilters()
            notes = try await noteService.searchNotes(query: searchText, filters: filters)
        } catch {
            self.error = error
            Logger.ui.error("Failed to fetch notes", error: error)
        }
    }

    public func deleteNote(_ note: Note) async {
        do {
            try await noteService.deleteNote(note)
            await fetchNotes()
        } catch {
            self.error = error
            Logger.ui.error("Failed to delete note", error: error)
        }
    }

    public func toggleFavorite(_ note: Note) async {
        note.isFavorite.toggle()
        do {
            try persistenceController.save()
        } catch {
            self.error = error
            Logger.ui.error("Failed to toggle favorite", error: error)
        }
    }

    // MARK: - Private Methods

    private func buildFilters() -> NoteFilters {
        var filters = NoteFilters()

        switch selectedFilter {
        case .all:
            break
        case .favorites:
            filters.isFavorite = true
        case .today:
            filters.dateRange = Date().startOfDay...Date().endOfDay
        case .thisWeek:
            filters.dateRange = Date().startOfWeek...Date().endOfWeek
        case .withAudio:
            filters.hasAudio = true
        case .withEmotion:
            filters.hasEmotion = true
        }

        // Add sort option
        filters.sortBy = selectedSortOption.toServiceSortOption()

        return filters
    }
}

// MARK: - Helper Extensions

extension NoteListViewModel.SortOption {
    func toServiceSortOption() -> NoteService.SortOption {
        switch self {
        case .dateDescending:
            return .dateDescending
        case .dateAscending:
            return .dateAscending
        case .titleAscending:
            return .titleAscending
        case .qualityScore:
            return .qualityDescending
        }
    }
}

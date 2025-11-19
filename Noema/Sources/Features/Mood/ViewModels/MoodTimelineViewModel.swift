//
//  MoodTimelineViewModel.swift
//  Noema
//
//  Created on January 18, 2025.
//

import Foundation
import CoreData
import Combine

@MainActor
public final class MoodTimelineViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published public var timelineData: [MoodTimelineEntry] = []
    @Published public var selectedDate: Date = Date()
    @Published public var selectedEmotion: EmotionType?
    @Published public var isLoading: Bool = false
    @Published public var error: Error?

    // MARK: - Timeline Entry

    public struct MoodTimelineEntry: Identifiable {
        public let id: UUID
        public let date: Date
        public let emotion: EmotionalState
        public let note: Note?
    }

    // MARK: - Dependencies

    private let persistenceController: PersistenceController
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    public init(persistenceController: PersistenceController = .shared) {
        self.persistenceController = persistenceController

        setupBindings()
    }

    // MARK: - Setup

    private func setupBindings() {
        Publishers.CombineLatest($selectedDate, $selectedEmotion)
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] _, _ in
                Task { await self?.fetchTimelineData() }
            }
            .store(in: &cancellables)
    }

    // MARK: - Public Methods

    public func fetchTimelineData() async {
        isLoading = true
        defer { isLoading = false }

        do {
            timelineData = try await fetchTimeline()
        } catch {
            self.error = error
            Logger.ui.error("Failed to fetch timeline data", error: error)
        }
    }

    // MARK: - Private Methods

    private func fetchTimeline() async throws -> [MoodTimelineEntry] {
        return try await persistenceController.performInBackground { context in
            let request: NSFetchRequest<Note> = Note.fetchRequest()

            var predicates: [NSPredicate] = []

            // Date filter
            let startOfDay = self.selectedDate.startOfDay
            let endOfDay = self.selectedDate.endOfDay
            predicates.append(NSPredicate(format: "createdAt >= %@ AND createdAt <= %@", startOfDay as NSDate, endOfDay as NSDate))

            // Emotion filter
            if let emotion = self.selectedEmotion {
                predicates.append(NSPredicate(format: "moodSnapshot.primaryEmotion == %@", emotion.rawValue))
            }

            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
            request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]

            let notes = try context.fetch(request)

            return notes.compactMap { note -> MoodTimelineEntry? in
                guard let emotion = note.moodSnapshot else { return nil }
                return MoodTimelineEntry(
                    id: note.id,
                    date: note.createdAt,
                    emotion: emotion,
                    note: note
                )
            }
        }
    }
}

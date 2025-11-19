//
//  NoteDetailViewModel.swift
//  Noema
//
//  Created on January 18, 2025.
//

import Foundation
import CoreData
import Combine

@MainActor
public final class NoteDetailViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published public var note: Note
    @Published public var relatedNotes: [Note] = []
    @Published public var entities: [Entity] = []
    @Published public var isLoadingRelated: Bool = false
    @Published public var showingTranscription: Bool = false
    @Published public var error: Error?

    // MARK: - Dependencies

    private let noteService: NoteService
    private let entityService: EntityService

    // MARK: - Initialization

    public init(
        note: Note,
        noteService: NoteService = NoteService(),
        entityService: EntityService = EntityService()
    ) {
        self.note = note
        self.noteService = noteService
        self.entityService = entityService
    }

    // MARK: - Public Methods

    public func loadRelatedData() async {
        isLoadingRelated = true
        defer { isLoadingRelated = false }

        await withTaskGroup(of: Void.self) { group in
            // Load related notes
            group.addTask {
                await self.loadRelatedNotes()
            }

            // Load entities
            group.addTask {
                await self.loadEntities()
            }
        }
    }

    public func transcribeAudio() async {
        guard note.hasAudio else { return }

        do {
            try await noteService.transcribeNote(note)
            showingTranscription = true
        } catch {
            self.error = error
            Logger.ui.error("Failed to transcribe note", error: error)
        }
    }

    public func generateSummary() async {
        do {
            try await noteService.summarizeNote(note)
        } catch {
            self.error = error
            Logger.ui.error("Failed to generate summary", error: error)
        }
    }

    // MARK: - Private Methods

    private func loadRelatedNotes() async {
        do {
            relatedNotes = try await noteService.getRelatedNotes(for: note, limit: 5)
        } catch {
            Logger.ui.error("Failed to load related notes", error: error)
        }
    }

    private func loadEntities() async {
        entities = Array(note.entityMentions.compactMap { $0.entity })
    }
}

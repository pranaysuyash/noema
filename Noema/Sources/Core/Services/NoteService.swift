import Foundation
import CoreData
import AVFoundation
import Speech

// MARK: - NoteService

/// Service for managing notes - creation, transcription, analysis
public final class NoteService {

    // MARK: - Properties

    private let persistenceController: PersistenceController
    private let emotionService: EmotionAnalysisService
    private let entityService: EntityService

    // MARK: - Initialization

    public init(
        persistenceController: PersistenceController = .shared,
        emotionService: EmotionAnalysisService = .shared,
        entityService: EntityService = .shared
    ) {
        self.persistenceController = persistenceController
        self.emotionService = emotionService
        self.entityService = entityService
    }

    // MARK: - Singleton

    public static let shared = NoteService()

    // MARK: - Note Creation

    /// Create a new text note
    public func createTextNote(
        content: String,
        tags: [Tag]? = nil,
        folder: Folder? = nil
    ) async throws -> Note {
        try await persistenceController.performInBackground { context in
            let note = Note(context: context)
            note.content = content
            note.updateCounts()
            note.timeOfDay = TimeOfDay(from: Date())

            // Add tags
            if let tags = tags {
                note.tags = Set(tags)
            }

            note.folder = folder

            // Analyze emotion
            let emotion = try await self.emotionService.analyzeTextEmotion(text: content)
            note.moodSnapshot = emotion
            note.dominantEmotion = emotion.primaryEmotion
            note.emotionIntensity = emotion.emotionIntensity

            // Extract entities
            let entities = try await self.entityService.extractEntities(from: content)
            for entity in entities {
                let mention = EntityMention(context: context)
                mention.entity = entity
                mention.note = note
                mention.contextSnippet = String(content.prefix(100))
                mention.emotionalState = emotion
                note.entityMentions.insert(mention)
            }

            // Calculate quality score
            note.qualityScore = note.calculateQualityScore()
            note.contributedXP = Int(note.qualityScore * 10)

            try context.save()
            return note
        }
    }

    /// Create a new voice note
    public func createVoiceNote(
        audioURL: URL,
        tags: [Tag]? = nil,
        folder: Folder? = nil
    ) async throws -> Note {
        try await persistenceController.performInBackground { context in
            let note = Note(context: context)
            note.hasAudio = true
            note.audioURL = audioURL
            note.transcriptionStatus = .pending

            // Get audio duration
            let asset = AVAsset(url: audioURL)
            note.audioDuration = try await asset.load(.duration).seconds

            if let tags = tags {
                note.tags = Set(tags)
            }
            note.folder = folder

            try context.save()

            // Transcribe in background
            Task {
                try await self.transcribeNote(note)
            }

            return note
        }
    }

    // MARK: - Transcription

    /// Transcribe audio note
    public func transcribeNote(_ note: Note) async throws {
        guard let audioURL = note.audioURL, note.hasAudio else {
            throw NoteServiceError.noAudioAvailable
        }

        try await persistenceController.performInBackground { context in
            // Get note in this context
            guard let contextNote = try? context.existingObject(with: note.objectID) as? Note else {
                throw NoteServiceError.noteNotFound
            }

            contextNote.transcriptionStatus = .processing
            try context.save()

            // Perform transcription (placeholder - would use Whisper model)
            let transcription = try await self.performTranscription(audioURL: audioURL)

            contextNote.content = transcription
            contextNote.updateCounts()
            contextNote.transcriptionStatus = .completed

            // Analyze transcribed content
            let emotion = try await self.emotionService.analyzeTextEmotion(text: transcription)
            contextNote.moodSnapshot = emotion
            contextNote.dominantEmotion = emotion.primaryEmotion
            contextNote.emotionIntensity = emotion.emotionIntensity

            // Extract entities
            let entities = try await self.entityService.extractEntities(from: transcription)
            for entity in entities {
                let mention = EntityMention(context: context)
                mention.entity = entity
                mention.note = contextNote
                mention.contextSnippet = String(transcription.prefix(100))
                mention.emotionalState = emotion
                contextNote.entityMentions.insert(mention)
            }

            // Analyze voice emotion
            let voiceEmotion = try await self.emotionService.analyzeVoiceEmotion(audioURL: audioURL)
            if let emotion = contextNote.moodSnapshot {
                emotion.voicePitch = voiceEmotion.pitch
                emotion.voiceEnergy = voiceEmotion.energy
                emotion.speakingRate = voiceEmotion.speakingRate
            }

            contextNote.qualityScore = contextNote.calculateQualityScore()
            contextNote.contributedXP = Int(contextNote.qualityScore * 15) // Voice notes worth more XP

            try context.save()
        }
    }

    private func performTranscription(audioURL: URL) async throws -> String {
        // Placeholder implementation
        // In production, this would use Whisper model via Core ML
        return "Transcribed content from audio..."
    }

    // MARK: - Summarization

    /// Generate AI summary for a note
    public func summarizeNote(
        _ note: Note,
        detailLevel: SummaryDetailLevel = .standard
    ) async throws -> String {
        let content = note.content
        guard !content.isEmpty else {
            throw NoteServiceError.emptyContent
        }

        // Placeholder - would use on-device or cloud AI
        let sentences = content.components(separatedBy: ". ")
        let summaryLength: Int

        switch detailLevel {
        case .brief:
            summaryLength = min(2, sentences.count)
        case .standard:
            summaryLength = min(4, sentences.count)
        case .detailed:
            summaryLength = min(8, sentences.count)
        }

        let summary = sentences.prefix(summaryLength).joined(separator: ". ")
        return summary + (summary.hasSuffix(".") ? "" : ".")
    }

    // MARK: - Update & Delete

    /// Update note content
    public func updateNote(_ note: Note, content: String) async throws {
        try await persistenceController.performOnViewContext { context in
            note.content = content
            note.updateCounts()
            note.modifiedAt = Date()

            // Re-analyze emotion
            let emotion = try await self.emotionService.analyzeTextEmotion(text: content)
            note.moodSnapshot = emotion
            note.dominantEmotion = emotion.primaryEmotion

            try context.save()
        }
    }

    /// Delete note (soft delete by archiving)
    public func deleteNote(_ note: Note) async throws {
        try await persistenceController.performOnViewContext { context in
            note.isArchived = true
            try context.save()
        }
    }

    /// Permanently delete note
    public func permanentlyDeleteNote(_ note: Note) async throws {
        try await persistenceController.performOnViewContext { context in
            context.delete(note)
            try context.save()
        }
    }

    // MARK: - Search & Fetch

    /// Search notes
    public func searchNotes(
        query: String,
        filters: NoteFilters? = nil
    ) async throws -> [Note] {
        try await persistenceController.performInBackground { context in
            var predicates: [NSPredicate] = []

            // Text search
            if !query.isEmpty {
                predicates.append(NSPredicate(format: "content CONTAINS[cd] %@", query))
            }

            // Apply filters
            if let filters = filters {
                if let dateRange = filters.dateRange {
                    predicates.append(NSPredicate(
                        format: "createdAt >= %@ AND createdAt <= %@",
                        dateRange.lowerBound as NSDate,
                        dateRange.upperBound as NSDate
                    ))
                }

                if let tags = filters.tags, !tags.isEmpty {
                    predicates.append(NSPredicate(format: "ANY tags.name IN %@", tags))
                }

                if filters.hasAudio == true {
                    predicates.append(NSPredicate(format: "hasAudio == YES"))
                }
            }

            // Not archived
            predicates.append(NSPredicate(format: "isArchived == NO"))

            let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)

            let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
            fetchRequest.predicate = compoundPredicate
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]

            return try context.fetch(fetchRequest)
        }
    }

    /// Get related notes based on entities and emotions
    public func getRelatedNotes(for note: Note, limit: Int = 5) async throws -> [Note] {
        try await persistenceController.performInBackground { context in
            let entities = note.entityMentions.map { $0.entity }
            guard !entities.isEmpty else { return [] }

            let entityIDs = entities.map { $0.objectID }

            let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
            fetchRequest.predicate = NSPredicate(
                format: "ANY entityMentions.entity IN %@ AND self != %@ AND isArchived == NO",
                entityIDs,
                note
            )
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
            fetchRequest.fetchLimit = limit

            return try context.fetch(fetchRequest)
        }
    }

    /// Get all notes
    public func getAllNotes() async throws -> [Note] {
        try await persistenceController.fetch(
            entityName: "Note",
            predicate: NSPredicate(format: "isArchived == NO"),
            sortDescriptors: [NSSortDescriptor(key: "createdAt", ascending: false)]
        )
    }
}

// MARK: - Supporting Types

public enum SummaryDetailLevel {
    case brief       // 1-2 sentences
    case standard    // 3-5 sentences
    case detailed    // Full paragraph
}

public struct NoteFilters {
    public var dateRange: ClosedRange<Date>?
    public var tags: [String]?
    public var emotions: [EmotionType]?
    public var entities: [UUID]?
    public var minValence: Double?
    public var maxValence: Double?
    public var minEnergy: Double?
    public var hasAudio: Bool?

    public init(
        dateRange: ClosedRange<Date>? = nil,
        tags: [String]? = nil,
        emotions: [EmotionType]? = nil,
        entities: [UUID]? = nil,
        minValence: Double? = nil,
        maxValence: Double? = nil,
        minEnergy: Double? = nil,
        hasAudio: Bool? = nil
    ) {
        self.dateRange = dateRange
        self.tags = tags
        self.emotions = emotions
        self.entities = entities
        self.minValence = minValence
        self.maxValence = maxValence
        self.minEnergy = minEnergy
        self.hasAudio = hasAudio
    }
}

// MARK: - Errors

public enum NoteServiceError: LocalizedError {
    case noAudioAvailable
    case transcriptionFailed
    case noteNotFound
    case emptyContent

    public var errorDescription: String? {
        switch self {
        case .noAudioAvailable:
            return "No audio file available for transcription"
        case .transcriptionFailed:
            return "Failed to transcribe audio"
        case .noteNotFound:
            return "Note not found"
        case .emptyContent:
            return "Note content is empty"
        }
    }
}

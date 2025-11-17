import Foundation

/// Represents a single note with content, metadata, and relationships
public struct Note: Identifiable, Equatable, Codable, Sendable {
    // MARK: - Properties

    public let id: UUID
    public var content: String
    public let createdAt: Date
    public var modifiedAt: Date

    // MARK: - Relationships

    public var mood: MoodSnapshot?
    public var entities: [NamedEntity]
    public var summary: String?
    public var audioURL: URL?
    public var transcription: Transcription?
    public var tags: [Tag]
    public var location: Location?
    public var weather: WeatherSnapshot?

    // MARK: - Metadata

    public var isFavorite: Bool
    public var isArchived: Bool

    // MARK: - Initialization

    public init(
        id: UUID = UUID(),
        content: String,
        createdAt: Date = Date(),
        modifiedAt: Date = Date(),
        mood: MoodSnapshot? = nil,
        entities: [NamedEntity] = [],
        summary: String? = nil,
        audioURL: URL? = nil,
        transcription: Transcription? = nil,
        tags: [Tag] = [],
        location: Location? = nil,
        weather: WeatherSnapshot? = nil,
        isFavorite: Bool = false,
        isArchived: Bool = false
    ) {
        self.id = id
        self.content = content
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
        self.mood = mood
        self.entities = entities
        self.summary = summary
        self.audioURL = audioURL
        self.transcription = transcription
        self.tags = tags
        self.location = location
        self.weather = weather
        self.isFavorite = isFavorite
        self.isArchived = isArchived
    }

    // MARK: - Computed Properties

    /// Word count of the note content
    public var wordCount: Int {
        content.split(separator: " ").count
    }

    /// Estimated reading time in minutes (assuming 200 words per minute)
    public var estimatedReadingTime: TimeInterval {
        Double(wordCount) / 200.0
    }

    /// Formatted reading time string
    public var readingTimeFormatted: String {
        let minutes = Int(ceil(estimatedReadingTime))
        return minutes == 1 ? "1 min" : "\(minutes) mins"
    }

    /// Check if note is recent within given interval
    public func isRecent(within interval: TimeInterval) -> Bool {
        Date().timeIntervalSince(createdAt) < interval
    }

    /// Check if note was created today
    public var isFromToday: Bool {
        Calendar.current.isDateInToday(createdAt)
    }

    /// Check if note has any AI-generated content
    public var hasAIContent: Bool {
        mood != nil || !entities.isEmpty || summary != nil || transcription != nil
    }

    /// Check if note has audio recording
    public var hasAudio: Bool {
        audioURL != nil || transcription != nil
    }

    // MARK: - Business Logic

    /// Update the modification timestamp
    public mutating func touch() {
        modifiedAt = Date()
    }

    /// Add a tag to the note
    public mutating func addTag(_ tag: Tag) {
        guard !tags.contains(where: { $0.id == tag.id }) else { return }
        tags.append(tag)
        touch()
    }

    /// Remove a tag from the note
    public mutating func removeTag(_ tag: Tag) {
        tags.removeAll(where: { $0.id == tag.id })
        touch()
    }

    /// Toggle favorite status
    public mutating func toggleFavorite() {
        isFavorite.toggle()
        touch()
    }

    /// Archive the note
    public mutating func archive() {
        isArchived = true
        touch()
    }

    /// Unarchive the note
    public mutating func unarchive() {
        isArchived = false
        touch()
    }
}

// MARK: - Hashable Conformance

extension Note: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Sample Data (for previews and testing)

#if DEBUG
extension Note {
    public static let sampleNotes: [Note] = [
        Note(
            content: "Had a great conversation with Sarah about the new project. She has some brilliant ideas about user engagement.",
            mood: .sample,
            summary: "Productive discussion with Sarah about project engagement strategies",
            tags: [.work, .ideas],
            isFavorite: true
        ),
        Note(
            content: "Feeling anxious about the presentation tomorrow. Need to practice more and prepare better slides.",
            mood: MoodSnapshot(
                timestamp: Date(),
                dimensions: EmotionalDimensions(
                    joy: 0.2, sadness: 0.3, anger: 0.1, fear: 0.7,
                    surprise: 0.1, disgust: 0.0, trust: 0.4, anticipation: 0.6
                )!,
                confidence: 0.85,
                source: .text
            ),
            tags: [.work, .personal]
        ),
        Note(
            content: "Amazing sunset at the beach today. Feeling grateful for these peaceful moments.",
            mood: MoodSnapshot(
                timestamp: Date(),
                dimensions: EmotionalDimensions(
                    joy: 0.9, sadness: 0.0, anger: 0.0, fear: 0.0,
                    surprise: 0.3, disgust: 0.0, trust: 0.8, anticipation: 0.2
                )!,
                confidence: 0.92,
                source: .text
            ),
            tags: [.personal, .gratitude],
            isFavorite: true
        ),
    ]

    public static var sample: Note {
        sampleNotes[0]
    }
}
#endif

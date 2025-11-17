import Foundation

/// Represents a complete transcription of an audio recording
public struct Transcription: Identifiable, Equatable, Codable, Sendable {
    // MARK: - Properties

    public let id: UUID
    public let text: String
    public let language: String // ISO language code (e.g., "en", "es", "fr")
    public let confidence: Float // Average confidence score [0.0, 1.0]
    public let duration: TimeInterval // Audio duration in seconds
    public let createdAt: Date
    public var segments: [TranscriptionSegment]

    // MARK: - Initialization

    public init(
        id: UUID = UUID(),
        text: String,
        language: String = "en",
        confidence: Float,
        duration: TimeInterval,
        createdAt: Date = Date(),
        segments: [TranscriptionSegment] = []
    ) {
        self.id = id
        self.text = text
        self.language = language
        self.confidence = min(1.0, max(0.0, confidence))
        self.duration = duration
        self.createdAt = createdAt
        self.segments = segments
    }

    // MARK: - Computed Properties

    /// Word count of transcribed text
    public var wordCount: Int {
        text.split(separator: " ").count
    }

    /// Words per minute (speaking rate)
    public var wordsPerMinute: Double {
        guard duration > 0 else { return 0.0 }
        return Double(wordCount) / (duration / 60.0)
    }

    /// Check if transcription is high confidence
    public var isHighConfidence: Bool {
        confidence >= 0.9
    }

    /// Number of speakers detected (if diarization was performed)
    public var speakerCount: Int {
        Set(segments.compactMap { $0.speakerID }).count
    }

    /// Language display name
    public var languageDisplayName: String {
        Locale.current.localizedString(forLanguageCode: language) ?? language
    }
}

/// Represents a segment of transcribed audio (e.g., a sentence or phrase)
public struct TranscriptionSegment: Identifiable, Equatable, Codable, Sendable {
    public let id: UUID
    public let text: String
    public let startTime: TimeInterval // Seconds from start
    public let endTime: TimeInterval
    public let confidence: Float
    public let speakerID: Int? // For speaker diarization

    public init(
        id: UUID = UUID(),
        text: String,
        startTime: TimeInterval,
        endTime: TimeInterval,
        confidence: Float,
        speakerID: Int? = nil
    ) {
        self.id = id
        self.text = text
        self.startTime = startTime
        self.endTime = endTime
        self.confidence = min(1.0, max(0.0, confidence))
        self.speakerID = speakerID
    }

    public var duration: TimeInterval {
        endTime - startTime
    }

    public var startTimeFormatted: String {
        let minutes = Int(startTime) / 60
        let seconds = Int(startTime) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Sample Data

#if DEBUG
extension Transcription {
    public static var sample: Transcription {
        Transcription(
            text: "Had a great conversation with Sarah about the new project. She has some brilliant ideas about user engagement.",
            language: "en",
            confidence: 0.94,
            duration: 8.5,
            segments: [
                TranscriptionSegment(
                    text: "Had a great conversation with Sarah about the new project.",
                    startTime: 0.0,
                    endTime: 3.2,
                    confidence: 0.96
                ),
                TranscriptionSegment(
                    text: "She has some brilliant ideas about user engagement.",
                    startTime: 3.5,
                    endTime: 8.5,
                    confidence: 0.92
                ),
            ]
        )
    }
}
#endif

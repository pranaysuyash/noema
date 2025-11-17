import Foundation

/// Represents a single mood measurement at a specific point in time
public struct MoodSnapshot: Identifiable, Equatable, Codable, Sendable, Hashable {
    // MARK: - Properties

    public let id: UUID
    public let timestamp: Date
    public let dimensions: EmotionalDimensions
    public let confidence: Float // AI confidence score [0.0, 1.0]
    public let source: MoodSource
    public var contextNote: String?

    // MARK: - Initialization

    public init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        dimensions: EmotionalDimensions,
        confidence: Float,
        source: MoodSource,
        contextNote: String? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.dimensions = dimensions
        self.confidence = confidence
        self.source = source
        self.contextNote = contextNote
    }

    // MARK: - Computed Properties

    /// Human-readable emotion label
    public var emotionLabel: String {
        dimensions.dominantEmotion.capitalized
    }

    /// Confidence as percentage string
    public var confidencePercentage: String {
        String(format: "%.0f%%", confidence * 100)
    }

    /// Check if this is a high-confidence mood detection
    public var isHighConfidence: Bool {
        confidence >= 0.8
    }

    /// Check if mood was detected by AI (vs. manually logged)
    public var isAIDetected: Bool {
        source == .text || source == .voice
    }

    /// Formatted timestamp
    public var timestampFormatted: String {
        timestamp.formatted(date: .abbreviated, time: .shortened)
    }

    // MARK: - Mood Quality Helpers

    /// Check if mood is primarily positive
    public var isPositiveMood: Bool {
        dimensions.isPositive
    }

    /// Check if mood is primarily negative
    public var isNegativeMood: Bool {
        dimensions.isNegative
    }

    /// Check if mood is neutral
    public var isNeutralMood: Bool {
        dimensions.isNeutral
    }

    /// Get emotional valence (-1 to 1)
    public var valence: Float {
        dimensions.valence
    }

    /// Get emotional arousal level (0 to 1)
    public var arousal: Float {
        dimensions.arousal
    }

    /// Full mood description
    public var moodDescription: String {
        var description = dimensions.description

        if let context = contextNote, !context.isEmpty {
            description += " - \(context)"
        }

        if !isHighConfidence {
            description += " (uncertain)"
        }

        return description
    }
}

// MARK: - Sample Data

#if DEBUG
extension MoodSnapshot {
    public static let samples: [MoodSnapshot] = [
        MoodSnapshot(
            timestamp: Date().addingTimeInterval(-3600), // 1 hour ago
            dimensions: EmotionalDimensions(
                joy: 0.8, sadness: 0.1, anger: 0.0, fear: 0.1,
                surprise: 0.2, disgust: 0.0, trust: 0.7, anticipation: 0.4
            )!,
            confidence: 0.92,
            source: .text,
            contextNote: "Great meeting with the team"
        ),
        MoodSnapshot(
            timestamp: Date().addingTimeInterval(-7200), // 2 hours ago
            dimensions: EmotionalDimensions(
                joy: 0.3, sadness: 0.6, anger: 0.2, fear: 0.4,
                surprise: 0.0, disgust: 0.1, trust: 0.3, anticipation: 0.1
            )!,
            confidence: 0.85,
            source: .voice,
            contextNote: "Feeling overwhelmed"
        ),
        MoodSnapshot(
            timestamp: Date().addingTimeInterval(-10800), // 3 hours ago
            dimensions: EmotionalDimensions(
                joy: 0.5, sadness: 0.2, anger: 0.0, fear: 0.0,
                surprise: 0.1, disgust: 0.0, trust: 0.6, anticipation: 0.3
            )!,
            confidence: 1.0,
            source: .manual
        ),
    ]

    public static var sample: MoodSnapshot {
        samples[0]
    }
}
#endif

import Foundation

/// Default implementation of AnalyzeMoodUseCase
public actor DefaultAnalyzeMoodUseCase: AnalyzeMoodUseCase {
    // MARK: - Execute

    public init() {}

    public func execute(text: String) async throws -> MoodSnapshot {
        // TODO: Implement actual AI mood analysis
        // For now, return a simulated mood based on simple keyword matching

        let lowercasedText = text.lowercased()
        var dimensions = EmotionalDimensions.neutral

        // Simple keyword-based analysis
        if lowercasedText.contains("happy") || lowercasedText.contains("great") || lowercasedText.contains("wonderful") {
            dimensions = EmotionalDimensions(
                joy: 0.8,
                sadness: 0.1,
                anger: 0.0,
                fear: 0.0,
                surprise: 0.2,
                disgust: 0.0,
                trust: 0.6,
                anticipation: 0.5
            )
        } else if lowercasedText.contains("sad") || lowercasedText.contains("down") || lowercasedText.contains("depressed") {
            dimensions = EmotionalDimensions(
                joy: 0.1,
                sadness: 0.8,
                anger: 0.0,
                fear: 0.2,
                surprise: 0.0,
                disgust: 0.0,
                trust: 0.3,
                anticipation: 0.1
            )
        } else if lowercasedText.contains("angry") || lowercasedText.contains("mad") || lowercasedText.contains("frustrated") {
            dimensions = EmotionalDimensions(
                joy: 0.0,
                sadness: 0.2,
                anger: 0.8,
                fear: 0.1,
                surprise: 0.0,
                disgust: 0.3,
                trust: 0.1,
                anticipation: 0.0
            )
        } else if lowercasedText.contains("worried") || lowercasedText.contains("anxious") || lowercasedText.contains("scared") {
            dimensions = EmotionalDimensions(
                joy: 0.0,
                sadness: 0.3,
                anger: 0.0,
                fear: 0.8,
                surprise: 0.2,
                disgust: 0.0,
                trust: 0.2,
                anticipation: 0.4
            )
        }

        return MoodSnapshot(
            id: UUID(),
            timestamp: Date(),
            dimensions: dimensions,
            confidence: 0.7, // Simulated confidence
            source: .text,
            contextNote: nil
        )
    }
}

// MARK: - Neutral Dimensions Extension

extension EmotionalDimensions {
    static var neutral: EmotionalDimensions {
        EmotionalDimensions(
            joy: 0.5,
            sadness: 0.0,
            anger: 0.0,
            fear: 0.0,
            surprise: 0.0,
            disgust: 0.0,
            trust: 0.5,
            anticipation: 0.3
        )
    }
}

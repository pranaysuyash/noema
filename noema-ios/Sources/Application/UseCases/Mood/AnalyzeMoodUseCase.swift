import Foundation

/// Use case for analyzing mood from note content
public protocol AnalyzeMoodUseCase: Sendable {
    /// Analyze mood from text content
    /// - Parameters:
    ///   - text: The text to analyze
    ///   - source: The source of the text (text, voice, etc.)
    /// - Returns: Detected mood snapshot
    /// - Throws: Error if analysis fails
    func execute(text: String, source: MoodSource) async throws -> MoodSnapshot
}

/// Default implementation of AnalyzeMoodUseCase
public actor DefaultAnalyzeMoodUseCase: AnalyzeMoodUseCase {
    // MARK: - Dependencies

    private let moodRepository: MoodRepositoryProtocol
    private let userProfileRepository: UserProfileRepositoryProtocol

    // MARK: - Initialization

    public init(
        moodRepository: MoodRepositoryProtocol,
        userProfileRepository: UserProfileRepositoryProtocol
    ) {
        self.moodRepository = moodRepository
        self.userProfileRepository = userProfileRepository
    }

    // MARK: - Execution

    public func execute(text: String, source: MoodSource) async throws -> MoodSnapshot {
        // Validate input
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw MoodError.emptyText
        }

        // TODO: Integrate with AI emotion detection model
        // For now, return a placeholder mood
        let dimensions = EmotionalDimensions(
            joy: 0.5, sadness: 0.2, anger: 0.1, fear: 0.1,
            surprise: 0.1, disgust: 0.0, trust: 0.6, anticipation: 0.4
        )!

        let mood = MoodSnapshot(
            timestamp: Date(),
            dimensions: dimensions,
            confidence: 0.75,
            source: source
        )

        // Save mood
        let savedMood = try await moodRepository.save(mood)

        // Update statistics (fire and forget)
        Task.detached { [userProfileRepository] in
            try? await userProfileRepository.incrementMoodCount()
        }

        return savedMood
    }
}

// MARK: - Errors

public enum MoodError: Error, LocalizedError {
    case emptyText
    case analysiFailed(underlying: Error)
    case lowConfidence

    public var errorDescription: String? {
        switch self {
        case .emptyText:
            return "Cannot analyze mood from empty text"
        case .analysisFailed(let error):
            return "Mood analysis failed: \(error.localizedDescription)"
        case .lowConfidence:
            return "Mood detection confidence is too low"
        }
    }
}

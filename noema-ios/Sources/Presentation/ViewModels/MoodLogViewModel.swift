import SwiftUI

/// ViewModel for logging a new mood entry
/// Handles manual mood entry with optional notes
@MainActor
public final class MoodLogViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published public var selectedEmotions: [String: Float] = [:]
    @Published public var contextNote: String = ""
    @Published public var isSaving: Bool = false
    @Published public var error: Error?
    @Published public var showingSuccessMessage: Bool = false

    // MARK: - Dependencies

    private let moodRepository: MoodRepositoryProtocol

    // MARK: - Initialization

    public init(moodRepository: MoodRepositoryProtocol) {
        self.moodRepository = moodRepository
        initializeEmotions()
    }

    // MARK: - Public Methods

    public func updateEmotion(_ emotion: String, intensity: Float) {
        selectedEmotions[emotion] = max(0.0, min(1.0, intensity))
    }

    public func saveMood() async {
        guard !selectedEmotions.isEmpty else {
            error = MoodLogError.noEmotionsSelected
            return
        }

        isSaving = true
        error = nil

        do {
            let dimensions = EmotionalDimensions(
                joy: selectedEmotions["joy"] ?? 0.0,
                sadness: selectedEmotions["sadness"] ?? 0.0,
                anger: selectedEmotions["anger"] ?? 0.0,
                fear: selectedEmotions["fear"] ?? 0.0,
                surprise: selectedEmotions["surprise"] ?? 0.0,
                disgust: selectedEmotions["disgust"] ?? 0.0,
                trust: selectedEmotions["trust"] ?? 0.0,
                anticipation: selectedEmotions["anticipation"] ?? 0.0
            )

            let mood = MoodSnapshot(
                id: UUID(),
                timestamp: Date(),
                dimensions: dimensions,
                confidence: 1.0,  // Manual entry is 100% confident
                source: .manual,
                contextNote: contextNote.isEmpty ? nil : contextNote
            )

            _ = try await moodRepository.save(mood)

            showingSuccessMessage = true
            resetForm()

            // Hide success message after 2 seconds
            try await Task.sleep(nanoseconds: 2_000_000_000)
            showingSuccessMessage = false

        } catch {
            self.error = error
        }

        isSaving = false
    }

    public func resetForm() {
        initializeEmotions()
        contextNote = ""
    }

    // MARK: - Private Methods

    private func initializeEmotions() {
        selectedEmotions = [
            "joy": 0.0,
            "sadness": 0.0,
            "anger": 0.0,
            "fear": 0.0,
            "surprise": 0.0,
            "disgust": 0.0,
            "trust": 0.0,
            "anticipation": 0.0
        ]
    }
}

// MARK: - Mood Log Error

public enum MoodLogError: Error, LocalizedError {
    case noEmotionsSelected
    case saveFailed

    public var errorDescription: String? {
        switch self {
        case .noEmotionsSelected:
            return "Please select at least one emotion"
        case .saveFailed:
            return "Failed to save mood entry"
        }
    }
}

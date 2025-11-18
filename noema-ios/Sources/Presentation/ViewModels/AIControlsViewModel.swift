import SwiftUI

/// ViewModel for AI controls screen
/// Manages AI feature settings and preferences
@MainActor
public final class AIControlsViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published public var aiSettings: AISettings
    @Published public var modelInfo: [AIModelInfo] = []
    @Published public var isLoading: Bool = false
    @Published public var error: Error?

    // MARK: - Initialization

    public init() {
        self.aiSettings = Self.loadAISettings()
    }

    // MARK: - Public Methods

    public func loadAIControls() async {
        isLoading = true
        error = nil

        loadModelInfo()

        isLoading = false
    }

    public func updateAISettings(_ settings: AISettings) {
        aiSettings = settings
        Self.saveAISettings(settings)
    }

    public func testMoodDetection() async throws -> EmotionalDimensions {
        // TODO: Implement mood detection test
        let testText = "I'm feeling great today! Had a wonderful morning."

        // Simulated response
        try await Task.sleep(nanoseconds: 1_000_000_000)

        return EmotionalDimensions(
            joy: 0.85,
            sadness: 0.05,
            anger: 0.0,
            fear: 0.0,
            surprise: 0.1,
            disgust: 0.0,
            trust: 0.7,
            anticipation: 0.6
        )
    }

    // MARK: - Private Methods

    private func loadModelInfo() {
        modelInfo = [
            AIModelInfo(
                name: "Emotion Detection",
                model: "DistilBERT-Emotion",
                size: "66 MB",
                processingLocation: aiSettings.useCloudAI ? .cloud : .device,
                accuracy: "94.2%"
            ),
            AIModelInfo(
                name: "Transcription",
                model: "Whisper Small",
                size: "244 MB",
                processingLocation: .device,
                accuracy: "96.8%"
            ),
            AIModelInfo(
                name: "Summarization",
                model: "BART-Summary",
                size: "158 MB",
                processingLocation: aiSettings.useCloudAI ? .cloud : .device,
                accuracy: "91.5%"
            ),
            AIModelInfo(
                name: "Entity Extraction",
                model: "NER-Custom",
                size: "42 MB",
                processingLocation: .device,
                accuracy: "88.3%"
            )
        ]
    }

    // MARK: - Static Helpers

    private static func loadAISettings() -> AISettings {
        AISettings(
            moodDetectionEnabled: UserDefaults.standard.bool(forKey: "ai_moodDetectionEnabled"),
            autoSummarization: UserDefaults.standard.bool(forKey: "ai_autoSummarization"),
            entityExtraction: UserDefaults.standard.bool(forKey: "ai_entityExtraction"),
            useCloudAI: UserDefaults.standard.bool(forKey: "ai_useCloudAI"),
            preferredLanguage: UserDefaults.standard.string(forKey: "ai_preferredLanguage") ?? "en"
        )
    }

    private static func saveAISettings(_ settings: AISettings) {
        UserDefaults.standard.set(settings.moodDetectionEnabled, forKey: "ai_moodDetectionEnabled")
        UserDefaults.standard.set(settings.autoSummarization, forKey: "ai_autoSummarization")
        UserDefaults.standard.set(settings.entityExtraction, forKey: "ai_entityExtraction")
        UserDefaults.standard.set(settings.useCloudAI, forKey: "ai_useCloudAI")
        UserDefaults.standard.set(settings.preferredLanguage, forKey: "ai_preferredLanguage")
    }
}

// MARK: - AI Model Info

public struct AIModelInfo: Identifiable {
    public let id = UUID()
    public let name: String
    public let model: String
    public let size: String
    public let processingLocation: ProcessingLocation
    public let accuracy: String

    public enum ProcessingLocation {
        case device
        case cloud

        public var displayName: String {
            switch self {
            case .device: return "On-Device"
            case .cloud: return "Cloud"
            }
        }

        public var icon: String {
            switch self {
            case .device: return "iphone"
            case .cloud: return "cloud"
            }
        }
    }
}

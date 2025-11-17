import Foundation

/// Represents the source/method of mood detection
public enum MoodSource: String, Codable, Sendable, CaseIterable {
    /// Mood detected from written text analysis
    case text

    /// Mood detected from voice tone analysis
    case voice

    /// Mood manually logged by user
    case manual

    /// Mood inferred from behavioral patterns
    case behavioral

    // MARK: - Display Properties

    /// Human-readable label
    public var label: String {
        switch self {
        case .text:
            return "Text Analysis"
        case .voice:
            return "Voice Analysis"
        case .manual:
            return "Manual Entry"
        case .behavioral:
            return "Pattern Recognition"
        }
    }

    /// SF Symbol name for icon
    public var iconName: String {
        switch self {
        case .text:
            return "text.bubble.fill"
        case .voice:
            return "waveform"
        case .manual:
            return "hand.tap.fill"
        case .behavioral:
            return "chart.line.uptrend.xyaxis"
        }
    }

    /// Is this an AI-detected source?
    public var isAIDetected: Bool {
        switch self {
        case .text, .voice, .behavioral:
            return true
        case .manual:
            return false
        }
    }

    /// Typical confidence range for this source
    public var typicalConfidenceRange: ClosedRange<Float> {
        switch self {
        case .text:
            return 0.75...0.95
        case .voice:
            return 0.70...0.90
        case .manual:
            return 1.0...1.0 // Manual entries are always 100% confidence
        case .behavioral:
            return 0.60...0.80
        }
    }
}

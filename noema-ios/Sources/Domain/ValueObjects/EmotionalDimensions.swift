import Foundation

/// Represents emotional state across 8 fundamental dimensions based on Plutchik's wheel of emotions
/// All values are normalized to [0.0, 1.0] range
public struct EmotionalDimensions: Equatable, Codable, Sendable, Hashable {
    // MARK: - Dimensions

    public let joy: Float          // Happiness, pleasure
    public let sadness: Float      // Sorrow, grief
    public let anger: Float        // Frustration, irritation
    public let fear: Float         // Anxiety, worry
    public let surprise: Float     // Astonishment, amazement
    public let disgust: Float      // Aversion, revulsion
    public let trust: Float        // Confidence, acceptance
    public let anticipation: Float // Expectation, interest

    // MARK: - Initialization

    /// Creates an emotional dimensions instance with validation
    /// Returns nil if any dimension is outside [0.0, 1.0] range
    public init?(
        joy: Float,
        sadness: Float,
        anger: Float,
        fear: Float,
        surprise: Float,
        disgust: Float,
        trust: Float,
        anticipation: Float
    ) {
        // Validate all dimensions are in valid range
        let dimensions = [joy, sadness, anger, fear, surprise, disgust, trust, anticipation]
        guard dimensions.allSatisfy({ $0 >= 0.0 && $0 <= 1.0 }) else {
            return nil
        }

        self.joy = joy
        self.sadness = sadness
        self.anger = anger
        self.fear = fear
        self.surprise = surprise
        self.disgust = disgust
        self.trust = trust
        self.anticipation = anticipation
    }

    /// Creates neutral emotional state (all dimensions at 0.0)
    public static var neutral: EmotionalDimensions {
        EmotionalDimensions(
            joy: 0.0, sadness: 0.0, anger: 0.0, fear: 0.0,
            surprise: 0.0, disgust: 0.0, trust: 0.0, anticipation: 0.0
        )!
    }

    // MARK: - Computed Properties

    /// Returns the dominant emotion as a string
    public var dominantEmotion: String {
        let emotions: [(name: String, value: Float)] = [
            ("joy", joy),
            ("sadness", sadness),
            ("anger", anger),
            ("fear", fear),
            ("surprise", surprise),
            ("disgust", disgust),
            ("trust", trust),
            ("anticipation", anticipation)
        ]

        guard let dominant = emotions.max(by: { $0.value < $1.value }) else {
            return "neutral"
        }

        // If dominant emotion is very low, return neutral
        return dominant.value > 0.2 ? dominant.name : "neutral"
    }

    /// Returns the dominant emotion value
    public var dominantValue: Float {
        let values = [joy, sadness, anger, fear, surprise, disgust, trust, anticipation]
        return values.max() ?? 0.0
    }

    /// Emotional valence: positive/negative scale [-1.0, 1.0]
    /// Positive emotions increase valence, negative emotions decrease it
    public var valence: Float {
        let positive = joy + trust + anticipation
        let negative = sadness + anger + fear + disgust
        return (positive - negative) / 8.0 // Normalized to [-1, 1]
    }

    /// Arousal level: how energized/activated the emotion is [0.0, 1.0]
    /// High arousal: anger, fear, joy, surprise
    /// Low arousal: sadness, trust, disgust, anticipation
    public var arousal: Float {
        let highArousal = anger + fear + joy + surprise
        let lowArousal = sadness + trust + disgust + anticipation
        let totalArousal = highArousal * 0.75 + lowArousal * 0.25
        return totalArousal / 8.0 // Normalized to [0, 1]
    }

    /// Emotional intensity: overall strength of emotions [0.0, 1.0]
    public var intensity: Float {
        let sum = joy + sadness + anger + fear + surprise + disgust + trust + anticipation
        return sum / 8.0
    }

    /// User-friendly description of emotional state
    public var description: String {
        let valenceLowel: String

        switch valence {
        case 0.3...1.0:
            valenceLowel = "positive"
        case -1.0 ... -0.3:
            valenceLowel = "negative"
        default:
            valenceLowel = "neutral"
        }

        let arousalLevel: String
        switch arousal {
        case 0.6...1.0:
            arousalLevel = "energized"
        case 0.3..<0.6:
            arousalLevel = "moderate"
        default:
            arousalLevel = "calm"
        }

        return "\(dominantEmotion) (\(valenceLowel), \(arousalLevel))"
    }

    // MARK: - Emotional State Helpers

    /// Check if emotion is primarily positive
    public var isPositive: Bool {
        valence > 0.2
    }

    /// Check if emotion is primarily negative
    public var isNegative: Bool {
        valence < -0.2
    }

    /// Check if emotion is neutral
    public var isNeutral: Bool {
        !isPositive && !isNegative
    }

    /// Check if in a high-arousal state
    public var isHighArousal: Bool {
        arousal > 0.6
    }

    /// Check if in a low-arousal state
    public var isLowArousal: Bool {
        arousal < 0.3
    }

    // MARK: - Color Representation

    /// Returns a color hex string representing the emotional state
    public var colorHex: String {
        switch dominantEmotion {
        case "joy":
            return "#FFD700" // Gold
        case "sadness":
            return "#4A90E2" // Blue
        case "anger":
            return "#E74C3C" // Red
        case "fear":
            return "#9B59B6" // Purple
        case "surprise":
            return "#F39C12" // Orange
        case "disgust":
            return "#16A085" // Teal
        case "trust":
            return "#27AE60" // Green
        case "anticipation":
            return "#E67E22" // Burnt Orange
        default:
            return "#95A5A6" // Gray
        }
    }

    // MARK: - Similarity

    /// Calculate cosine similarity with another emotional state
    /// Returns value in [0.0, 1.0] where 1.0 is identical
    public func similarity(to other: EmotionalDimensions) -> Float {
        let thisVector = [joy, sadness, anger, fear, surprise, disgust, trust, anticipation]
        let otherVector = [other.joy, other.sadness, other.anger, other.fear,
                          other.surprise, other.disgust, other.trust, other.anticipation]

        var dotProduct: Float = 0.0
        var thisMagnitude: Float = 0.0
        var otherMagnitude: Float = 0.0

        for i in 0..<8 {
            dotProduct += thisVector[i] * otherVector[i]
            thisMagnitude += thisVector[i] * thisVector[i]
            otherMagnitude += otherVector[i] * otherVector[i]
        }

        thisMagnitude = sqrt(thisMagnitude)
        otherMagnitude = sqrt(otherMagnitude)

        guard thisMagnitude > 0 && otherMagnitude > 0 else {
            return 0.0
        }

        return dotProduct / (thisMagnitude * otherMagnitude)
    }

    // MARK: - Array Representation

    /// Returns dimensions as an array for ML processing
    public var asArray: [Float] {
        [joy, sadness, anger, fear, surprise, disgust, trust, anticipation]
    }

    /// Creates dimensions from an array
    public static func from(array: [Float]) -> EmotionalDimensions? {
        guard array.count == 8 else { return nil }
        return EmotionalDimensions(
            joy: array[0], sadness: array[1], anger: array[2], fear: array[3],
            surprise: array[4], disgust: array[5], trust: array[6], anticipation: array[7]
        )
    }
}

// MARK: - Sample Data

#if DEBUG
extension EmotionalDimensions {
    public static let samples: [EmotionalDimensions] = [
        // Happy
        EmotionalDimensions(
            joy: 0.85, sadness: 0.05, anger: 0.0, fear: 0.0,
            surprise: 0.2, disgust: 0.0, trust: 0.7, anticipation: 0.3
        )!,
        // Sad
        EmotionalDimensions(
            joy: 0.1, sadness: 0.8, anger: 0.1, fear: 0.3,
            surprise: 0.0, disgust: 0.1, trust: 0.2, anticipation: 0.0
        )!,
        // Anxious
        EmotionalDimensions(
            joy: 0.2, sadness: 0.4, anger: 0.2, fear: 0.75,
            surprise: 0.3, disgust: 0.0, trust: 0.3, anticipation: 0.6
        )!,
        // Excited
        EmotionalDimensions(
            joy: 0.75, sadness: 0.0, anger: 0.0, fear: 0.1,
            surprise: 0.5, disgust: 0.0, trust: 0.6, anticipation: 0.85
        )!,
        // Neutral
        EmotionalDimensions.neutral,
    ]

    public static var sample: EmotionalDimensions {
        samples[0]
    }
}
#endif

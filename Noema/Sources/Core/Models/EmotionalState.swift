import Foundation
import CoreData

// MARK: - EmotionalState Model

/// Represents a snapshot of emotional state at a specific moment
/// Based on Russell's Circumplex Model of Affect
@objc(EmotionalState)
public class EmotionalState: NSManagedObject, Identifiable {

    // MARK: - Identity

    @NSManaged public var id: UUID
    @NSManaged public var timestamp: Date

    // MARK: - Core Dimensions (Russell's Circumplex Model)

    /// Valence: -1.0 (very negative) to 1.0 (very positive)
    @NSManaged public var valence: Double

    /// Arousal: -1.0 (very calm) to 1.0 (very excited/activated)
    @NSManaged public var arousal: Double

    /// Dominance: -1.0 (submissive/controlled) to 1.0 (dominant/in-control)
    @NSManaged public var dominance: Double

    // MARK: - Additional Dimensions

    /// Energy Level: 0.0 (exhausted) to 1.0 (energized)
    @NSManaged public var energyLevel: Double

    /// Stress Level: 0.0 (relaxed) to 1.0 (stressed)
    @NSManaged public var stressLevel: Double

    /// Focus Level: 0.0 (scattered) to 1.0 (focused)
    @NSManaged public var focusLevel: Double

    // MARK: - Emotion Classification

    @NSManaged private var primaryEmotionRaw: String
    @NSManaged private var secondaryEmotionsRaw: String?  // Comma-separated for Core Data

    public var primaryEmotion: EmotionType {
        get {
            EmotionType(rawValue: primaryEmotionRaw) ?? .contentment
        }
        set {
            primaryEmotionRaw = newValue.rawValue
        }
    }

    public var secondaryEmotions: [EmotionType] {
        get {
            guard let raw = secondaryEmotionsRaw else { return [] }
            return raw.split(separator: ",")
                .compactMap { EmotionType(rawValue: String($0)) }
        }
        set {
            secondaryEmotionsRaw = newValue.map { $0.rawValue }.joined(separator: ",")
        }
    }

    /// Emotion Intensity: 0.0 (mild) to 1.0 (intense)
    @NSManaged public var emotionIntensity: Double

    // MARK: - Detection Source & Confidence

    @NSManaged private var detectionSourcesRaw: String?  // Comma-separated

    public var detectionSources: [DetectionSource] {
        get {
            guard let raw = detectionSourcesRaw else { return [] }
            return raw.split(separator: ",")
                .compactMap { DetectionSource(rawValue: String($0)) }
        }
        set {
            detectionSourcesRaw = newValue.map { $0.rawValue }.joined(separator: ",")
        }
    }

    /// Confidence: 0.0 to 1.0
    @NSManaged public var confidence: Double

    // MARK: - Context

    @NSManaged public var note: Note?
    @NSManaged public var trigger: String?

    // MARK: - Voice Characteristics (if from audio)

    @NSManaged public var voicePitch: Double
    @NSManaged public var voiceEnergy: Double
    @NSManaged public var speakingRate: Double
    @NSManaged public var pauseFrequency: Double

    // MARK: - Biometric Data (HealthKit, if available)

    @NSManaged public var heartRate: Double
    @NSManaged public var heartRateVariability: Double

    // MARK: - Computed Properties

    /// Emotional state as a descriptive string
    public var stateDescription: String {
        let emotionName = primaryEmotion.displayName
        let intensityDesc: String

        if emotionIntensity > 0.7 {
            intensityDesc = "very \(emotionName)"
        } else if emotionIntensity > 0.4 {
            intensityDesc = "moderately \(emotionName)"
        } else {
            intensityDesc = "mildly \(emotionName)"
        }

        return intensityDesc
    }

    /// Wellness score: Combination of valence balance and stress
    public var wellnessScore: Double {
        let valenceScore = (valence + 1) / 2  // Normalize to 0-1
        let stressScore = 1.0 - stressLevel
        let energyScore = energyLevel

        return (valenceScore * 0.4 + stressScore * 0.3 + energyScore * 0.3)
    }

    // MARK: - Initialization

    public override func awakeFromInsert() {
        super.awakeFromInsert()

        id = UUID()
        timestamp = Date()
        valence = 0
        arousal = 0
        dominance = 0
        energyLevel = 0.5
        stressLevel = 0
        focusLevel = 0.5
        primaryEmotion = .contentment
        emotionIntensity = 0
        confidence = 0
        voicePitch = 0
        voiceEnergy = 0
        speakingRate = 0
        pauseFrequency = 0
        heartRate = 0
        heartRateVariability = 0
    }
}

// MARK: - EmotionType Enum

public enum EmotionType: String, Codable, CaseIterable {
    // Basic Emotions (Ekman's 6)
    case joy
    case sadness
    case anger
    case fear
    case disgust
    case surprise

    // Extended Emotions
    case anxiety
    case excitement
    case contentment
    case frustration
    case pride
    case shame
    case guilt
    case gratitude
    case love
    case hope
    case boredom
    case confusion
    case curiosity
    case determination
    case enthusiasm

    // Complex/Mixed
    case bittersweet
    case nostalgic
    case overwhelmed
    case peaceful
    case restless

    public var displayName: String {
        rawValue.capitalized
    }

    /// Emoji representation for UI
    public var emoji: String {
        switch self {
        case .joy: return "😊"
        case .sadness: return "😢"
        case .anger: return "😠"
        case .fear: return "😨"
        case .disgust: return "🤢"
        case .surprise: return "😲"
        case .anxiety: return "😰"
        case .excitement: return "🤩"
        case .contentment: return "😌"
        case .frustration: return "😤"
        case .pride: return "😎"
        case .shame: return "😳"
        case .guilt: return "😔"
        case .gratitude: return "🙏"
        case .love: return "🥰"
        case .hope: return "🌟"
        case .boredom: return "😐"
        case .confusion: return "🤔"
        case .curiosity: return "🧐"
        case .determination: return "💪"
        case .enthusiasm: return "🎉"
        case .bittersweet: return "🥲"
        case .nostalgic: return "💭"
        case .overwhelmed: return "😵"
        case .peaceful: return "🧘"
        case .restless: return "😖"
        }
    }

    /// Color representation for UI (hex string)
    public var colorHex: String {
        switch self {
        case .joy: return "#FFD700"  // Gold
        case .sadness: return "#4682B4"  // Steel Blue
        case .anger: return "#DC143C"  // Crimson
        case .fear: return "#9370DB"  // Medium Purple
        case .disgust: return "#9ACD32"  // Yellow Green
        case .surprise: return "#FF8C00"  // Dark Orange
        case .anxiety: return "#FF6347"  // Tomato
        case .excitement: return "#FF1493"  // Deep Pink
        case .contentment: return "#87CEEB"  // Sky Blue
        case .frustration: return "#8B4513"  // Saddle Brown
        case .pride: return "#FFD700"  // Gold
        case .shame: return "#A9A9A9"  // Dark Gray
        case .guilt: return "#696969"  // Dim Gray
        case .gratitude: return "#FF69B4"  // Hot Pink
        case .love: return "#FF1493"  // Deep Pink
        case .hope: return "#00CED1"  // Dark Turquoise
        case .boredom: return "#808080"  // Gray
        case .confusion: return "#DDA0DD"  // Plum
        case .curiosity: return "#40E0D0"  // Turquoise
        case .determination: return "#B22222"  // Fire Brick
        case .enthusiasm: return "#FF4500"  // Orange Red
        case .bittersweet: return "#DB7093"  // Pale Violet Red
        case .nostalgic: return "#DAA520"  // Goldenrod
        case .overwhelmed: return "#8B008B"  // Dark Magenta
        case .peaceful: return "#98FB98"  // Pale Green
        case .restless: return "#FA8072"  // Salmon
        }
    }
}

// MARK: - DetectionSource Enum

public enum DetectionSource: String, Codable {
    case textSentiment      // NLP sentiment analysis
    case voiceTone          // Paralinguistic analysis
    case biometric          // HealthKit data
    case environmental      // Weather, location
    case userManual         // User explicitly set
}

// MARK: - Extensions

extension EmotionalState {

    /// Returns VAD coordinates as a tuple
    public var vadCoordinates: (valence: Double, arousal: Double, dominance: Double) {
        (valence, arousal, dominance)
    }

    /// Determine quadrant in 2D valence-arousal space
    public var emotionalQuadrant: EmotionalQuadrant {
        if valence >= 0 && arousal >= 0 {
            return .highEnergyPositive  // Excited, Happy
        } else if valence >= 0 && arousal < 0 {
            return .lowEnergyPositive   // Calm, Content
        } else if valence < 0 && arousal >= 0 {
            return .highEnergyNegative  // Angry, Anxious
        } else {
            return .lowEnergyNegative   // Sad, Depressed
        }
    }

    /// Similar emotional states (used for pattern matching)
    public func similarity(to other: EmotionalState) -> Double {
        // Euclidean distance in VAD space
        let valenceDiff = valence - other.valence
        let arousalDiff = arousal - other.arousal
        let dominanceDiff = dominance - other.dominance

        let distance = sqrt(valenceDiff * valenceDiff +
                           arousalDiff * arousalDiff +
                           dominanceDiff * dominanceDiff)

        // Convert distance to similarity (0 = different, 1 = identical)
        // Max distance in VAD space is sqrt(3) * 2 ≈ 3.46
        return max(0, 1 - (distance / 3.46))
    }
}

public enum EmotionalQuadrant {
    case highEnergyPositive   // Quadrant I (excited, happy, enthusiastic)
    case highEnergyNegative   // Quadrant II (angry, anxious, stressed)
    case lowEnergyNegative    // Quadrant III (sad, depressed, tired)
    case lowEnergyPositive    // Quadrant IV (calm, content, peaceful)

    public var description: String {
        switch self {
        case .highEnergyPositive:
            return "Energized & Positive"
        case .highEnergyNegative:
            return "Energized & Negative"
        case .lowEnergyNegative:
            return "Low Energy & Negative"
        case .lowEnergyPositive:
            return "Calm & Positive"
        }
    }
}

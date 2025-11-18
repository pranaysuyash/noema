import Foundation
import CoreData
import NaturalLanguage
import AVFoundation

// MARK: - EmotionAnalysisService

/// Service for emotion detection, analysis, and pattern recognition
public final class EmotionAnalysisService {

    // MARK: - Properties

    private let persistenceController: PersistenceController
    private let sentimentAnalyzer = NLTagger(tagSchemes: [.sentimentScore])

    // MARK: - Initialization

    public init(persistenceController: PersistenceController = .shared) {
        self.persistenceController = persistenceController
    }

    // MARK: - Singleton

    public static let shared = EmotionAnalysisService()

    // MARK: - Text Emotion Analysis

    /// Analyze emotion from text
    public func analyzeTextEmotion(text: String) async throws -> EmotionalState {
        try await persistenceController.performInBackground { context in
            let emotion = EmotionalState(context: context)
            emotion.timestamp = Date()

            // Use NaturalLanguage framework for sentiment
            self.sentimentAnalyzer.string = text
            let (sentiment, _) = self.sentimentAnalyzer.tag(at: text.startIndex, unit: .paragraph, scheme: .sentimentScore)

            // Convert sentiment to valence (-1 to 1)
            if let sentiment = sentiment {
                emotion.valence = Double(sentiment.rawValue) ?? 0.0
            } else {
                emotion.valence = 0.0
            }

            // Analyze arousal based on text characteristics
            emotion.arousal = self.calculateArousal(from: text)

            // Analyze dominance
            emotion.dominance = self.calculateDominance(from: text)

            // Calculate other dimensions
            emotion.energyLevel = (emotion.arousal + 1) / 2 // Normalize to 0-1
            emotion.stressLevel = max(0, -emotion.valence * emotion.arousal) // High arousal + negative valence = stress
            emotion.focusLevel = 0.5 // Default, would be calculated from other factors

            // Determine primary emotion
            emotion.primaryEmotion = self.determinePrimaryEmotion(
                valence: emotion.valence,
                arousal: emotion.arousal
            )

            // Set intensity
            emotion.emotionIntensity = sqrt(emotion.valence * emotion.valence + emotion.arousal * emotion.arousal) / sqrt(2)

            // Set detection source
            emotion.detectionSources = [.textSentiment]
            emotion.confidence = 0.8

            try context.save()
            return emotion
        }
    }

    private func calculateArousal(from text: String) -> Double {
        // Analyze text characteristics that indicate arousal
        let exclamationCount = text.filter { $0 == "!" }.count
        let questionCount = text.filter { $0 == "?" }.count
        let capsRatio = Double(text.filter { $0.isUppercase }.count) / Double(max(1, text.count))

        // High energy words
        let highEnergyWords = ["excited", "amazing", "terrible", "awful", "incredible", "shocking"]
        let energyWordCount = highEnergyWords.reduce(0) { count, word in
            count + text.lowercased().components(separatedBy: word).count - 1
        }

        let arousal = min(1.0, (
            Double(exclamationCount) * 0.2 +
            Double(questionCount) * 0.1 +
            capsRatio * 0.3 +
            Double(energyWordCount) * 0.1
        ))

        return arousal * 2 - 1 // Convert to -1 to 1 range
    }

    private func calculateDominance(from text: String) -> Double {
        // Analyze text for power/control indicators
        let powerWords = ["I will", "I can", "I must", "I should", "I have to"]
        let uncertainWords = ["maybe", "perhaps", "possibly", "might", "unsure"]

        var dominance = 0.0

        for word in powerWords {
            if text.lowercased().contains(word.lowercased()) {
                dominance += 0.2
            }
        }

        for word in uncertainWords {
            if text.lowercased().contains(word.lowercased()) {
                dominance -= 0.2
            }
        }

        return max(-1.0, min(1.0, dominance))
    }

    private func determinePrimaryEmotion(valence: Double, arousal: Double) -> EmotionType {
        // Use Russell's circumplex model
        if valence > 0.3 && arousal > 0.3 {
            return .excitement
        } else if valence > 0.3 && arousal < -0.3 {
            return .contentment
        } else if valence < -0.3 && arousal > 0.3 {
            return .anxiety
        } else if valence < -0.3 && arousal < -0.3 {
            return .sadness
        } else if valence > 0.5 {
            return .joy
        } else if valence < -0.5 {
            return .sadness
        } else {
            return .contentment
        }
    }

    // MARK: - Voice Emotion Analysis

    /// Analyze emotion from voice characteristics
    public func analyzeVoiceEmotion(audioURL: URL) async throws -> VoiceEmotionData {
        let asset = AVAsset(url: audioURL)

        // Extract audio characteristics (placeholder - would use signal processing)
        let duration = try await asset.load(.duration).seconds

        // Placeholder values - in production would analyze audio signal
        let pitch = 150.0 + Double.random(in: -30...30)
        let energy = Double.random(in: 0.3...0.9)
        let speakingRate = 120.0 + Double.random(in: -20...40) // words per minute

        // Determine emotion from voice characteristics
        var emotion: EmotionType = .contentment
        if pitch > 170 && energy > 0.7 {
            emotion = .excitement
        } else if pitch < 130 && energy < 0.4 {
            emotion = .sadness
        } else if energy > 0.8 && speakingRate > 140 {
            emotion = .anxiety
        }

        return VoiceEmotionData(
            pitch: pitch,
            pitchVariability: Double.random(in: 0.1...0.4),
            energy: energy,
            speakingRate: speakingRate,
            pauseFrequency: Double.random(in: 0.05...0.2),
            detectedEmotion: emotion,
            confidence: 0.7
        )
    }

    /// Combine multi-modal emotion signals
    public func combineEmotionSignals(
        text: EmotionalState?,
        voice: VoiceEmotionData?,
        biometric: BiometricData? = nil
    ) async throws -> EmotionalState {
        guard let baseEmotion = text else {
            throw EmotionServiceError.noEmotionData
        }

        // Weight the signals
        var valence = baseEmotion.valence * 0.5
        var arousal = baseEmotion.arousal * 0.5
        var confidence = baseEmotion.confidence * 0.5

        if let voice = voice {
            // Voice contributes to arousal
            let voiceArousal = (voice.energy - 0.5) * 2 // Convert 0-1 to -1 to 1
            arousal += voiceArousal * 0.3
            confidence += voice.confidence * 0.3
        }

        if let biometric = biometric {
            // Heart rate contributes to arousal
            if let hr = biometric.heartRate {
                let normalizedHR = (hr - 70) / 30 // Normalize around resting heart rate
                arousal += min(1, max(-1, normalizedHR)) * 0.2
            }
            confidence += 0.2
        }

        // Update emotion
        baseEmotion.valence = max(-1, min(1, valence))
        baseEmotion.arousal = max(-1, min(1, arousal))
        baseEmotion.confidence = min(1, confidence)

        // Update primary emotion based on combined signals
        baseEmotion.primaryEmotion = determinePrimaryEmotion(
            valence: baseEmotion.valence,
            arousal: baseEmotion.arousal
        )

        // Update detection sources
        var sources: [DetectionSource] = [.textSentiment]
        if voice != nil { sources.append(.voiceTone) }
        if biometric != nil { sources.append(.biometric) }
        baseEmotion.detectionSources = sources

        return baseEmotion
    }

    // MARK: - Pattern Analysis

    /// Get emotional patterns over time
    public func getEmotionalPatterns(
        dateRange: ClosedRange<Date>
    ) async throws -> EmotionalPatterns {
        try await persistenceController.performInBackground { context in
            let fetchRequest: NSFetchRequest<EmotionalState> = EmotionalState.fetchRequest()
            fetchRequest.predicate = NSPredicate(
                format: "timestamp >= %@ AND timestamp <= %@",
                dateRange.lowerBound as NSDate,
                dateRange.upperBound as NSDate
            )
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true)]

            let emotions = try context.fetch(fetchRequest)

            // Analyze time of day patterns
            var timeOfDayPattern: [TimeOfDay: [Double]] = [:]
            for emotion in emotions {
                let timeOfDay = TimeOfDay(from: emotion.timestamp)
                timeOfDayPattern[timeOfDay, default: []].append(emotion.valence)
            }

            let timeOfDayAverage = timeOfDayPattern.mapValues { values in
                values.reduce(0, +) / Double(values.count)
            }

            // Analyze day of week patterns
            let calendar = Calendar.current
            var dayOfWeekPattern: [Int: [Double]] = [:]
            for emotion in emotions {
                let day = calendar.component(.weekday, from: emotion.timestamp)
                dayOfWeekPattern[day, default: []].append(emotion.valence)
            }

            let dayOfWeekAverage = dayOfWeekPattern.mapValues { values in
                values.reduce(0, +) / Double(values.count)
            }

            // Find peak energy time (placeholder)
            let peakEnergyTime = Date()
            let lowEnergyTime = Date().addingTimeInterval(-6 * 3600)

            return EmotionalPatterns(
                timeOfDayPattern: timeOfDayAverage,
                dayOfWeekPattern: dayOfWeekAverage,
                seasonalPattern: [:],
                circadianRhythm: CircadianPattern(
                    peakEnergyTime: peakEnergyTime,
                    lowEnergyTime: lowEnergyTime,
                    moodAmplitude: 0.5
                )
            )
        }
    }

    /// Predict mood based on context
    public func predictMood(context: MoodContext) async throws -> EmotionalStatePrediction {
        // Placeholder implementation - would use LSTM model
        let predictedState = try await analyzeTextEmotion(text: "neutral mood")

        return EmotionalStatePrediction(
            predictedState: predictedState,
            confidence: 0.6,
            reasoning: "Based on your typical patterns at this time"
        )
    }

    /// Detect emotional anomalies
    public func detectAnomalies(threshold: Double = 2.0) async throws -> [EmotionalAnomaly] {
        try await persistenceController.performInBackground { context in
            // Get recent emotions (last 30 days)
            let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date())!
            let fetchRequest: NSFetchRequest<EmotionalState> = EmotionalState.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "timestamp >= %@", thirtyDaysAgo as NSDate)

            let emotions = try context.fetch(fetchRequest)

            guard !emotions.isEmpty else { return [] }

            // Calculate mean and standard deviation
            let valences = emotions.map { $0.valence }
            let mean = valences.reduce(0, +) / Double(valences.count)
            let variance = valences.map { pow($0 - mean, 2) }.reduce(0, +) / Double(valences.count)
            let stdDev = sqrt(variance)

            // Find anomalies (values beyond threshold standard deviations)
            var anomalies: [EmotionalAnomaly] = []
            for emotion in emotions {
                let zScore = abs(emotion.valence - mean) / stdDev
                if zScore > threshold {
                    let type: AnomalyType = emotion.valence > mean ? .unusuallyPositive : .unusuallyNegative
                    anomalies.append(EmotionalAnomaly(
                        timestamp: emotion.timestamp,
                        state: emotion,
                        deviationScore: zScore,
                        type: type
                    ))
                }
            }

            return anomalies.sorted { $0.deviationScore > $1.deviationScore }
        }
    }

    /// Generate insights from emotional data
    public func generateInsights() async throws -> [EmotionalInsight] {
        var insights: [EmotionalInsight] = []

        // Get patterns from last 30 days
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date())!
        let patterns = try await getEmotionalPatterns(dateRange: thirtyDaysAgo...Date())

        // Find best time of day
        if let bestTime = patterns.timeOfDayPattern.max(by: { $0.value < $1.value }) {
            insights.append(EmotionalInsight(
                title: "Peak Energy Time",
                description: "You're most energized during \(bestTime.key.rawValue)",
                type: .pattern,
                impact: .high,
                relatedEntities: nil,
                actionableAdvice: "Schedule important tasks during this time"
            ))
        }

        // Find best day of week
        if let bestDay = patterns.dayOfWeekPattern.max(by: { $0.value < $1.value }) {
            let dayName = Calendar.current.weekdaySymbols[bestDay.key - 1]
            insights.append(EmotionalInsight(
                title: "Best Day",
                description: "You're happiest on \(dayName)s",
                type: .pattern,
                impact: .medium,
                relatedEntities: nil,
                actionableAdvice: "Plan enjoyable activities for this day"
            ))
        }

        return insights
    }
}

// MARK: - Supporting Types

public struct VoiceEmotionData {
    public var pitch: Double
    public var pitchVariability: Double
    public var energy: Double
    public var speakingRate: Double
    public var pauseFrequency: Double
    public var detectedEmotion: EmotionType
    public var confidence: Double

    public init(pitch: Double, pitchVariability: Double, energy: Double, speakingRate: Double, pauseFrequency: Double, detectedEmotion: EmotionType, confidence: Double) {
        self.pitch = pitch
        self.pitchVariability = pitchVariability
        self.energy = energy
        self.speakingRate = speakingRate
        self.pauseFrequency = pauseFrequency
        self.detectedEmotion = detectedEmotion
        self.confidence = confidence
    }
}

public struct BiometricData {
    public var heartRate: Double?
    public var heartRateVariability: Double?
    public var sleepQuality: Double?
    public var activityLevel: Double?

    public init(heartRate: Double? = nil, heartRateVariability: Double? = nil, sleepQuality: Double? = nil, activityLevel: Double? = nil) {
        self.heartRate = heartRate
        self.heartRateVariability = heartRateVariability
        self.sleepQuality = sleepQuality
        self.activityLevel = activityLevel
    }
}

public struct EmotionalPatterns {
    public var timeOfDayPattern: [TimeOfDay: Double]
    public var dayOfWeekPattern: [Int: Double]
    public var seasonalPattern: [Season: Double]
    public var circadianRhythm: CircadianPattern

    public init(timeOfDayPattern: [TimeOfDay: Double], dayOfWeekPattern: [Int: Double], seasonalPattern: [Season: Double], circadianRhythm: CircadianPattern) {
        self.timeOfDayPattern = timeOfDayPattern
        self.dayOfWeekPattern = dayOfWeekPattern
        self.seasonalPattern = seasonalPattern
        self.circadianRhythm = circadianRhythm
    }
}

public struct CircadianPattern {
    public var peakEnergyTime: Date
    public var lowEnergyTime: Date
    public var moodAmplitude: Double

    public init(peakEnergyTime: Date, lowEnergyTime: Date, moodAmplitude: Double) {
        self.peakEnergyTime = peakEnergyTime
        self.lowEnergyTime = lowEnergyTime
        self.moodAmplitude = moodAmplitude
    }
}

public struct MoodContext {
    public var time: Date
    public var location: Location?
    public var weather: WeatherSnapshot?
    public var recentSleep: Double?
    public var recentExercise: Double?

    public init(time: Date, location: Location? = nil, weather: WeatherSnapshot? = nil, recentSleep: Double? = nil, recentExercise: Double? = nil) {
        self.time = time
        self.location = location
        self.weather = weather
        self.recentSleep = recentSleep
        self.recentExercise = recentExercise
    }
}

public struct EmotionalStatePrediction {
    public var predictedState: EmotionalState
    public var confidence: Double
    public var reasoning: String

    public init(predictedState: EmotionalState, confidence: Double, reasoning: String) {
        self.predictedState = predictedState
        self.confidence = confidence
        self.reasoning = reasoning
    }
}

public struct EmotionalAnomaly {
    public var timestamp: Date
    public var state: EmotionalState
    public var deviationScore: Double
    public var type: AnomalyType

    public init(timestamp: Date, state: EmotionalState, deviationScore: Double, type: AnomalyType) {
        self.timestamp = timestamp
        self.state = state
        self.deviationScore = deviationScore
        self.type = type
    }
}

public enum AnomalyType {
    case unusuallyPositive
    case unusuallyNegative
    case rapidChange
    case prolongedExtreme
}

public struct EmotionalInsight {
    public var title: String
    public var description: String
    public var type: InsightType
    public var impact: InsightImpact
    public var relatedEntities: [Entity]?
    public var actionableAdvice: String?

    public init(title: String, description: String, type: InsightType, impact: InsightImpact, relatedEntities: [Entity]?, actionableAdvice: String?) {
        self.title = title
        self.description = description
        self.type = type
        self.impact = impact
        self.relatedEntities = relatedEntities
        self.actionableAdvice = actionableAdvice
    }
}

public enum InsightType {
    case pattern
    case correlation
    case achievement
    case warning
    case opportunity
}

public enum InsightImpact {
    case low
    case medium
    case high
}

// MARK: - Errors

public enum EmotionServiceError: LocalizedError {
    case noEmotionData
    case analysisFailed

    public var errorDescription: String? {
        switch self {
        case .noEmotionData:
            return "No emotion data available"
        case .analysisFailed:
            return "Emotion analysis failed"
        }
    }
}

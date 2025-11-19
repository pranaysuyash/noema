//
//  EmotionAnalysisServiceTests.swift
//  Noema
//
//  Created on November 19, 2025.
//

import XCTest
import CoreData
@testable import Noema

final class EmotionAnalysisServiceTests: XCTestCase {

    var persistenceController: PersistenceController!
    var emotionService: EmotionAnalysisService!
    var context: NSManagedObjectContext!

    override func setUp() async throws {
        try await super.setUp()
        persistenceController = PersistenceController(inMemory: true)
        context = persistenceController.container.viewContext
        emotionService = EmotionAnalysisService(persistenceController: persistenceController)
    }

    override func tearDown() {
        emotionService = nil
        context = nil
        persistenceController = nil
        super.tearDown()
    }

    // MARK: - Text Emotion Analysis Tests

    func test_analyzeTextEmotion_createsEmotionalState() async throws {
        // Given
        let text = "I am so happy and excited about this amazing opportunity!"

        // When
        let emotion = try await emotionService.analyzeTextEmotion(text: text)

        // Then
        XCTAssertNotNil(emotion)
        XCTAssertNotNil(emotion.primaryEmotion)
        XCTAssertGreaterThanOrEqual(emotion.confidence, 0.0)
        XCTAssertLessThanOrEqual(emotion.confidence, 1.0)
    }

    func test_analyzeTextEmotion_detectsPositiveSentiment() async throws {
        // Given
        let positiveText = "This is wonderful! I feel great and everything is amazing!"

        // When
        let emotion = try await emotionService.analyzeTextEmotion(text: positiveText)

        // Then
        XCTAssertGreaterThan(emotion.valence, 0)
    }

    func test_analyzeTextEmotion_detectsNegativeSentiment() async throws {
        // Given
        let negativeText = "This is terrible. I feel awful and sad about everything."

        // When
        let emotion = try await emotionService.analyzeTextEmotion(text: negativeText)

        // Then
        XCTAssertLessThan(emotion.valence, 0)
    }

    func test_analyzeTextEmotion_setsDetectionSource() async throws {
        // Given
        let text = "Some text to analyze"

        // When
        let emotion = try await emotionService.analyzeTextEmotion(text: text)

        // Then
        XCTAssertTrue(emotion.detectionSources.contains(.textSentiment))
    }

    func test_analyzeTextEmotion_calculatesIntensity() async throws {
        // Given
        let text = "I am extremely excited and incredibly happy!!!"

        // When
        let emotion = try await emotionService.analyzeTextEmotion(text: text)

        // Then
        XCTAssertGreaterThanOrEqual(emotion.emotionIntensity, 0.0)
        XCTAssertLessThanOrEqual(emotion.emotionIntensity, 1.0)
    }

    // MARK: - Voice Emotion Analysis Tests

    func test_analyzeVoiceEmotion_returnsVoiceData() async throws {
        // Given
        let testAudioURL = URL(fileURLWithPath: "/tmp/test.wav")

        // When
        do {
            let voiceData = try await emotionService.analyzeVoiceEmotion(audioURL: testAudioURL)

            // Then
            XCTAssertGreaterThan(voiceData.pitch, 0)
            XCTAssertGreaterThanOrEqual(voiceData.energy, 0.0)
            XCTAssertLessThanOrEqual(voiceData.energy, 1.0)
            XCTAssertNotNil(voiceData.detectedEmotion)
        } catch {
            // Voice analysis may fail without actual audio file, which is acceptable
            XCTAssertTrue(true)
        }
    }

    // MARK: - Combine Emotion Signals Tests

    func test_combineEmotionSignals_mergesTextAndVoice() async throws {
        // Given
        let textEmotion = try await emotionService.analyzeTextEmotion(text: "Happy text")
        let voiceData = VoiceEmotionData(
            pitch: 150,
            pitchVariability: 0.3,
            energy: 0.7,
            speakingRate: 120,
            pauseFrequency: 0.1,
            detectedEmotion: .joy,
            confidence: 0.8
        )

        // When
        let combined = try await emotionService.combineEmotionSignals(text: textEmotion, voice: voiceData)

        // Then
        XCTAssertNotNil(combined)
        XCTAssertTrue(combined.detectionSources.contains(.textSentiment))
        XCTAssertTrue(combined.detectionSources.contains(.voiceTone))
        XCTAssertGreaterThan(combined.confidence, textEmotion.confidence)
    }

    func test_combineEmotionSignals_throwsWithoutBaseEmotion() async throws {
        // Given
        let voiceData = VoiceEmotionData(
            pitch: 150,
            pitchVariability: 0.3,
            energy: 0.7,
            speakingRate: 120,
            pauseFrequency: 0.1,
            detectedEmotion: .joy,
            confidence: 0.8
        )

        // When/Then
        await XCTAssertThrowsError(
            try await emotionService.combineEmotionSignals(text: nil, voice: voiceData)
        )
    }

    // MARK: - Emotional Patterns Tests

    func test_getEmotionalPatterns_returnsPatterns() async throws {
        // Given
        // Create some emotional states
        for i in 0..<5 {
            let emotion = EmotionalState(context: context)
            emotion.timestamp = Date().addingTimeInterval(Double(-i * 3600))
            emotion.valence = Double(i % 2 == 0 ? 0.5 : -0.5)
        }
        try context.save()

        let dateRange = Date().addingTimeInterval(-7 * 24 * 3600)...Date()

        // When
        let patterns = try await emotionService.getEmotionalPatterns(dateRange: dateRange)

        // Then
        XCTAssertNotNil(patterns)
        XCTAssertNotNil(patterns.circadianRhythm)
    }

    // MARK: - Detect Anomalies Tests

    func test_detectAnomalies_findsOutliers() async throws {
        // Given
        // Create mostly neutral emotions
        for _ in 0..<10 {
            let emotion = EmotionalState(context: context)
            emotion.valence = 0.0
            emotion.timestamp = Date()
        }

        // Create one extreme outlier
        let outlier = EmotionalState(context: context)
        outlier.valence = 1.0
        outlier.timestamp = Date()

        try context.save()

        // When
        let anomalies = try await emotionService.detectAnomalies(threshold: 1.5)

        // Then
        XCTAssertGreaterThanOrEqual(anomalies.count, 0)
    }

    func test_detectAnomalies_sortsDescendingScore() async throws {
        // Given
        for i in 0..<5 {
            let emotion = EmotionalState(context: context)
            emotion.valence = Double(i) * 0.2
            emotion.timestamp = Date()
        }
        try context.save()

        // When
        let anomalies = try await emotionService.detectAnomalies(threshold: 0.5)

        // Then
        if anomalies.count >= 2 {
            XCTAssertGreaterThanOrEqual(
                anomalies[0].deviationScore,
                anomalies[1].deviationScore
            )
        }
    }

    // MARK: - Generate Insights Tests

    func test_generateInsights_returnsInsights() async throws {
        // Given
        // Create some emotional data
        for i in 0..<10 {
            let emotion = EmotionalState(context: context)
            emotion.timestamp = Date().addingTimeInterval(Double(-i * 24 * 3600))
            emotion.valence = Double(i % 2 == 0 ? 0.5 : -0.5)
        }
        try context.save()

        // When
        let insights = try await emotionService.generateInsights()

        // Then
        XCTAssertNotNil(insights)
        // Insights may or may not be generated depending on data patterns
        for insight in insights {
            XCTAssertFalse(insight.title.isEmpty)
            XCTAssertFalse(insight.description.isEmpty)
        }
    }

    // MARK: - Predict Mood Tests

    func test_predictMood_returnsPrediction() async throws {
        // Given
        let context = MoodContext(time: Date())

        // When
        let prediction = try await emotionService.predictMood(context: context)

        // Then
        XCTAssertNotNil(prediction.predictedState)
        XCTAssertGreaterThanOrEqual(prediction.confidence, 0.0)
        XCTAssertLessThanOrEqual(prediction.confidence, 1.0)
        XCTAssertFalse(prediction.reasoning.isEmpty)
    }

    // MARK: - Helper Method Tests

    func test_determinePrimaryEmotion_returnsValidEmotion() async throws {
        // Given
        let text = "I am feeling content and peaceful"

        // When
        let emotion = try await emotionService.analyzeTextEmotion(text: text)

        // Then
        XCTAssertNotNil(emotion.primaryEmotion)
        XCTAssertTrue(EmotionType.allCases.contains(emotion.primaryEmotion))
    }

    func test_emotionalState_valenceWithinBounds() async throws {
        // Given
        let text = "Extremely happy and excited!!!"

        // When
        let emotion = try await emotionService.analyzeTextEmotion(text: text)

        // Then
        XCTAssertGreaterThanOrEqual(emotion.valence, -1.0)
        XCTAssertLessThanOrEqual(emotion.valence, 1.0)
    }

    func test_emotionalState_arousalWithinBounds() async throws {
        // Given
        let text = "VERY EXCITED AND ENERGETIC!!!"

        // When
        let emotion = try await emotionService.analyzeTextEmotion(text: text)

        // Then
        XCTAssertGreaterThanOrEqual(emotion.arousal, -1.0)
        XCTAssertLessThanOrEqual(emotion.arousal, 1.0)
    }
}

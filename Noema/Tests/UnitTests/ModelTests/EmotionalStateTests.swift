//
//  EmotionalStateTests.swift
//  Noema
//
//  Created on November 19, 2025.
//

import XCTest
import CoreData
@testable import Noema

final class EmotionalStateTests: XCTestCase {

    var persistenceController: PersistenceController!
    var context: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        persistenceController = PersistenceController(inMemory: true)
        context = persistenceController.container.viewContext
    }

    override func tearDown() {
        context = nil
        persistenceController = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func test_emotionalStateInitialization_setsDefaultValues() {
        // Given/When
        let emotion = EmotionalState(context: context)

        // Then
        XCTAssertNotNil(emotion.id)
        XCTAssertNotNil(emotion.timestamp)
        XCTAssertEqual(emotion.valence, 0)
        XCTAssertEqual(emotion.arousal, 0)
        XCTAssertEqual(emotion.dominance, 0)
        XCTAssertEqual(emotion.energyLevel, 0.5)
        XCTAssertEqual(emotion.stressLevel, 0)
        XCTAssertEqual(emotion.focusLevel, 0.5)
        XCTAssertEqual(emotion.primaryEmotion, .contentment)
    }

    // MARK: - VAD Coordinates Tests

    func test_vadCoordinates_returnsCorrectTuple() {
        // Given
        let emotion = EmotionalState(context: context)
        emotion.valence = 0.5
        emotion.arousal = 0.3
        emotion.dominance = 0.7

        // When
        let vad = emotion.vadCoordinates

        // Then
        XCTAssertEqual(vad.valence, 0.5)
        XCTAssertEqual(vad.arousal, 0.3)
        XCTAssertEqual(vad.dominance, 0.7)
    }

    // MARK: - Emotional Quadrant Tests

    func test_emotionalQuadrant_highEnergyPositive() {
        // Given
        let emotion = EmotionalState(context: context)
        emotion.valence = 0.5
        emotion.arousal = 0.5

        // When
        let quadrant = emotion.emotionalQuadrant

        // Then
        XCTAssertEqual(quadrant, .highEnergyPositive)
    }

    func test_emotionalQuadrant_lowEnergyPositive() {
        // Given
        let emotion = EmotionalState(context: context)
        emotion.valence = 0.5
        emotion.arousal = -0.5

        // When
        let quadrant = emotion.emotionalQuadrant

        // Then
        XCTAssertEqual(quadrant, .lowEnergyPositive)
    }

    func test_emotionalQuadrant_highEnergyNegative() {
        // Given
        let emotion = EmotionalState(context: context)
        emotion.valence = -0.5
        emotion.arousal = 0.5

        // When
        let quadrant = emotion.emotionalQuadrant

        // Then
        XCTAssertEqual(quadrant, .highEnergyNegative)
    }

    func test_emotionalQuadrant_lowEnergyNegative() {
        // Given
        let emotion = EmotionalState(context: context)
        emotion.valence = -0.5
        emotion.arousal = -0.5

        // When
        let quadrant = emotion.emotionalQuadrant

        // Then
        XCTAssertEqual(quadrant, .lowEnergyNegative)
    }

    // MARK: - Wellness Score Tests

    func test_wellnessScore_calculatesProperly() {
        // Given
        let emotion = EmotionalState(context: context)
        emotion.valence = 0.5
        emotion.stressLevel = 0.2
        emotion.energyLevel = 0.7

        // When
        let score = emotion.wellnessScore

        // Then
        XCTAssertGreaterThanOrEqual(score, 0.0)
        XCTAssertLessThanOrEqual(score, 1.0)
    }

    func test_wellnessScore_higherForPositiveState() {
        // Given
        let positiveEmotion = EmotionalState(context: context)
        positiveEmotion.valence = 0.8
        positiveEmotion.stressLevel = 0.1
        positiveEmotion.energyLevel = 0.8

        let negativeEmotion = EmotionalState(context: context)
        negativeEmotion.valence = -0.8
        negativeEmotion.stressLevel = 0.9
        negativeEmotion.energyLevel = 0.2

        // When
        let positiveScore = positiveEmotion.wellnessScore
        let negativeScore = negativeEmotion.wellnessScore

        // Then
        XCTAssertGreaterThan(positiveScore, negativeScore)
    }

    // MARK: - State Description Tests

    func test_stateDescription_includesEmotionName() {
        // Given
        let emotion = EmotionalState(context: context)
        emotion.primaryEmotion = .joy
        emotion.emotionIntensity = 0.5

        // When
        let description = emotion.stateDescription

        // Then
        XCTAssertTrue(description.lowercased().contains("joy"))
    }

    func test_stateDescription_varysByIntensity() {
        // Given
        let mildEmotion = EmotionalState(context: context)
        mildEmotion.primaryEmotion = .joy
        mildEmotion.emotionIntensity = 0.3

        let intenseEmotion = EmotionalState(context: context)
        intenseEmotion.primaryEmotion = .joy
        intenseEmotion.emotionIntensity = 0.8

        // When
        let mildDescription = mildEmotion.stateDescription
        let intenseDescription = intenseEmotion.stateDescription

        // Then
        XCTAssertNotEqual(mildDescription, intenseDescription)
        XCTAssertTrue(mildDescription.contains("mildly"))
        XCTAssertTrue(intenseDescription.contains("very"))
    }

    // MARK: - Similarity Tests

    func test_similarity_returnsOneForIdenticalStates() {
        // Given
        let emotion1 = EmotionalState(context: context)
        emotion1.valence = 0.5
        emotion1.arousal = 0.3
        emotion1.dominance = 0.7

        let emotion2 = EmotionalState(context: context)
        emotion2.valence = 0.5
        emotion2.arousal = 0.3
        emotion2.dominance = 0.7

        // When
        let similarity = emotion1.similarity(to: emotion2)

        // Then
        XCTAssertGreaterThan(similarity, 0.99) // Allow for floating point precision
    }

    func test_similarity_returnsLowerForDifferentStates() {
        // Given
        let emotion1 = EmotionalState(context: context)
        emotion1.valence = 0.8
        emotion1.arousal = 0.8
        emotion1.dominance = 0.8

        let emotion2 = EmotionalState(context: context)
        emotion2.valence = -0.8
        emotion2.arousal = -0.8
        emotion2.dominance = -0.8

        // When
        let similarity = emotion1.similarity(to: emotion2)

        // Then
        XCTAssertLessThan(similarity, 0.5)
    }

    // MARK: - EmotionType Tests

    func test_emotionType_hasDisplayName() {
        // Given
        let emotion = EmotionType.joy

        // When
        let displayName = emotion.displayName

        // Then
        XCTAssertEqual(displayName, "Joy")
    }

    func test_emotionType_hasEmoji() {
        // Given
        let emotion = EmotionType.joy

        // When
        let emoji = emotion.emoji

        // Then
        XCTAssertFalse(emoji.isEmpty)
    }

    func test_emotionType_hasColorHex() {
        // Given
        let emotion = EmotionType.joy

        // When
        let color = emotion.colorHex

        // Then
        XCTAssertTrue(color.hasPrefix("#"))
        XCTAssertEqual(color.count, 7)
    }

    // MARK: - Secondary Emotions Tests

    func test_secondaryEmotions_canBeSetAndRetrieved() {
        // Given
        let emotion = EmotionalState(context: context)
        let secondaryEmotions: [EmotionType] = [.excitement, .hope, .curiosity]

        // When
        emotion.secondaryEmotions = secondaryEmotions

        // Then
        XCTAssertEqual(emotion.secondaryEmotions.count, 3)
        XCTAssertTrue(emotion.secondaryEmotions.contains(.excitement))
        XCTAssertTrue(emotion.secondaryEmotions.contains(.hope))
        XCTAssertTrue(emotion.secondaryEmotions.contains(.curiosity))
    }

    // MARK: - Detection Sources Tests

    func test_detectionSources_canBeSetAndRetrieved() {
        // Given
        let emotion = EmotionalState(context: context)
        let sources: [DetectionSource] = [.textSentiment, .voiceTone, .biometric]

        // When
        emotion.detectionSources = sources

        // Then
        XCTAssertEqual(emotion.detectionSources.count, 3)
        XCTAssertTrue(emotion.detectionSources.contains(.textSentiment))
        XCTAssertTrue(emotion.detectionSources.contains(.voiceTone))
        XCTAssertTrue(emotion.detectionSources.contains(.biometric))
    }
}

//
//  AnalyticsService.swift
//  Noema
//
//  Created on January 18, 2025.
//

import Foundation

/// Privacy-preserving analytics service (opt-in only)
public final class AnalyticsService {
    public static let shared = AnalyticsService()

    private let persistenceController = PersistenceController.shared
    private var isEnabled: Bool = false

    private init() {
        loadPreferences()
    }

    // MARK: - Configuration

    private func loadPreferences() {
        // Load from UserDefaults
        isEnabled = UserDefaults.standard.bool(forKey: "analytics_enabled")
        Logger.analytics.info("Analytics enabled: \(isEnabled)")
    }

    public func setEnabled(_ enabled: Bool) {
        isEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: "analytics_enabled")
        Logger.analytics.info("Analytics \(enabled ? "enabled" : "disabled")")
    }

    // MARK: - Event Tracking (Privacy-Preserving)

    public func trackEvent(_ event: AnalyticsEvent) {
        guard isEnabled else { return }

        // Privacy-preserving: Only track aggregated, non-PII data
        Logger.analytics.info("Event: \(event.name) - Properties: \(event.properties)")

        // In production, send to analytics backend with privacy-preserving measures
        // For now, just log locally
    }

    public func trackScreenView(_ screen: String) {
        trackEvent(AnalyticsEvent(name: "screen_view", properties: ["screen": screen]))
    }

    public func trackNoteCreated(hasAudio: Bool, wordCount: Int, hasEmotion: Bool) {
        trackEvent(AnalyticsEvent(
            name: "note_created",
            properties: [
                "has_audio": hasAudio,
                "word_count_bucket": wordCountBucket(wordCount),
                "has_emotion": hasEmotion
            ]
        ))
    }

    public func trackFeatureUsed(_ feature: String) {
        trackEvent(AnalyticsEvent(name: "feature_used", properties: ["feature": feature]))
    }

    public func trackAchievementUnlocked(type: String, rarity: String) {
        trackEvent(AnalyticsEvent(
            name: "achievement_unlocked",
            properties: ["type": type, "rarity": rarity]
        ))
    }

    public func trackSubscriptionPurchased(tier: String) {
        trackEvent(AnalyticsEvent(
            name: "subscription_purchased",
            properties: ["tier": tier]
        ))
    }

    // MARK: - Usage Statistics

    public func getUsageStatistics() async throws -> UsageStatistics {
        return try await persistenceController.performInBackground { context in
            let noteRequest: NSFetchRequest<Note> = Note.fetchRequest()
            let totalNotes = try context.count(for: noteRequest)

            let voiceNoteRequest: NSFetchRequest<Note> = Note.fetchRequest()
            voiceNoteRequest.predicate = NSPredicate(format: "hasAudio == YES")
            let voiceNotes = try context.count(for: voiceNoteRequest)

            let emotionRequest: NSFetchRequest<EmotionalState> = EmotionalState.fetchRequest()
            let totalEmotions = try context.count(for: emotionRequest)

            let entityRequest: NSFetchRequest<Entity> = Entity.fetchRequest()
            let totalEntities = try context.count(for: entityRequest)

            return UsageStatistics(
                totalNotes: totalNotes,
                voiceNotes: voiceNotes,
                totalEmotions: totalEmotions,
                totalEntities: totalEntities
            )
        }
    }

    // MARK: - Private Helpers

    private func wordCountBucket(_ wordCount: Int) -> String {
        switch wordCount {
        case 0..<50: return "0-50"
        case 50..<100: return "50-100"
        case 100..<250: return "100-250"
        case 250..<500: return "250-500"
        default: return "500+"
        }
    }
}

// MARK: - Supporting Types

public struct AnalyticsEvent {
    let name: String
    let properties: [String: Any]
    let timestamp: Date

    init(name: String, properties: [String: Any]) {
        self.name = name
        self.properties = properties
        self.timestamp = Date()
    }
}

public struct UsageStatistics {
    let totalNotes: Int
    let voiceNotes: Int
    let totalEmotions: Int
    let totalEntities: Int
}
